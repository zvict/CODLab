## <center> 实验报告 </center>

实验题目：储存器与显示控制器

* ##### 实验要求

  * 设计一个画板：控制画笔子在800×600分辨率的显示器上随意涂画，画笔的颜色12位（红r绿g蓝b各4位），绘画区域位于屏幕正中央，大小为256×256

  * 画笔位置（x，y）：x = y = 0 ~ 255，复位时（128，128）

  * 移动画笔（dir）：上/下/左/右按钮

  * 画笔颜色（rgb）：12位开关设置

  * 绘画状态（draw）：1 - 是，0 - 否；处于绘画状态时，移动画笔同时绘制颜色，否则仅移动画笔

  * 加分项：实现画笔对角和连续移动处理，十字光标显示功能

    

* ##### 实验内容

  * 总控制单元与数据通路

    * VRAM：视频存储器，存储256×256个像素的颜色信息，调用IP核实现
    * PCU：绘画控制单元，修改VRAM中像素信息
    * DCU：显示控制单元，显示VRAM中像素信息

  * VRAM

    调用IP核实现，大小：65535×12

  * PCU

    ``` verilog
    module PCU(
        input clk,
        input rst,
        input [3:0]dir,
        input draw,
        input [3:0]in_R,				//VRAM写数据
        input [3:0]in_G,
        input [3:0]in_B,
        
        output [3:0]R,
        output [3:0]G,
        output [3:0]B,
        output VS,
        output HS
        );
            
        reg [7:0] x;					//VRAM写地址
        reg [7:0] y;
        
        wire [11:0]color;				//VRAM读数据
        wire [7:0]x_addr;				//VRAM读地址
        wire [7:0]y_addr;
        
        wire clk_50;					//显示用50MHz时钟
        wire clk_10;					//VRAM写用10MHz时钟，太快写时易出错
                            
        clk_wiz_0 clk50(
            .clk_in1(clk),
            .clk_out1(clk_50)
            );
        
        clk_wiz_1 clk10(
            .clk_in1(clk),
            .clk_out1(clk_10)
            );
            
        dist_mem_gen_0 mem(
            .a({x,y}),
            .d({in_R,in_G,in_B}),
            .clk(clk_10),
            .we(draw),
            .dpra({x_addr,y_addr}),
            .dpo(color)
            );
                
        DCU display(
            .clk(clk_50),
            .rst(rst),
            .x_addr(x_addr),
            .y_addr(y_addr),
            .x(x),
            .y(y),
            .vgaRed(R),
            .vgaGreen(G),
            .vgaBlue(B),
            .vgaHsync(HS),
            .vgaVsync(VS),
            .color(color)
            );
            
        wire clk_2;						//画笔移动时钟，1Hz
        reg [16:0]count_2;
        
        fdivision(rst,clk,clk_2);		//100MHz分频1Hz
        
        always @(posedge clk_2 or posedge rst)
        begin
            if(rst)
            begin
                x <= 8'd128;
                y <= 8'd128;
            end
            else
            begin
                case(dir)
                    4'b0000: ;
                    4'b0001:
                        x <= x + 1;
                    4'b0010:
                        y <= y + 1;
                    4'b0100:
                        x <= x - 1;
                    4'b1000:
                        y <= y - 1;
                    4'b0011:begin		//对角移动
                        x <= x + 1;
                        y <= y + 1;
                        end
                    4'b1001:begin
                        x <= x + 1;
                        y <= y - 1;
                        end
                    4'b0110:begin
                        x <= x - 1;
                        y <= y + 1;
                        end
                    4'b1100:begin
                        x <= x - 1;
                        y <= y - 1;
                        end
                    default: ;
                endcase
            end
        end
        
    endmodule
    
    module fdivision(
        input rst,
        input clk_in,
        output reg clk_out
        );
    
        reg [19:0] j;
        
        always @(posedge clk_in or posedge rst)
        begin
            if(rst)
            begin
                clk_out <= 0;
                j <= 0;
            end
            else
            begin
                if(j == 999999)
                begin
                    j <= 0;
                    clk_out <= ~clk_out;
                    end
                else
                    j <= j + 1;
            end
        end
    endmodule
    ```

  * DCU

    ``` verilog
    module DCU(
    	input clk,            		// 50MHz
    	input rst,
        input [7:0] x,
        input [7:0] y,
        
    	output [7:0] x_addr,
    	output [7:0] y_addr,
    	input [11:0] color,   
    	output [3:0] vgaRed,
    	output [3:0] vgaGreen,
    	output [3:0] vgaBlue,
    	output vgaHsync,
    	output vgaVsync
    	);
    
    
    	// 800x600@72Hz
    	parameter CLKF = 50;      	// clock frequency
    	parameter H_SYNC = 120;    	// horizontal sync pulse
    	parameter H_BEGIN = 456;  	// horizontal data begin
    	parameter H_END = 711;    	// horizontal data end
    	parameter H_PERIOD = 1040; 	// horizontal whole line length
    	parameter V_SYNC = 6;     	// vertical sync pulse
    	parameter V_BEGIN = 201;   	// vertical data begin
    	parameter V_END = 456;    	// vertical data end
    	parameter V_PERIOD = 666; 	// vertical whole frame length
    	
    	wire clk25;
    	wire vgaclk;
    	counter clk25c(clk, rst, 2, clk25);
    	assign vgaclk = (CLKF == 50) ? clk : clk25;
    
    	wire [10:0] hcount;
    	counter hc(vgaclk, rst, H_PERIOD, hcount);
    	assign vgaHsync = (hcount < H_SYNC) ? 0 : 1;
    	assign y_addr = hcount - H_BEGIN;
    
    	wire [9:0] vcount;
    	counter vc(~(hcount[10]), rst, V_PERIOD, vcount);
    	assign vgaVsync = (vcount < V_SYNC) ? 0 : 1;
    	assign x_addr = vcount - V_BEGIN;
    
    	wire de;					//有效区域使能
    	assign de = (vcount >= V_BEGIN) && (vcount < V_END) && (hcount >= H_BEGIN) && (hcount < H_END);
        
    	wire cross;					//十字光标使能
    	assign cross = ~(((vcount >= V_BEGIN + x - 5) && (vcount <= V_BEGIN + x + 5) && (hcount == H_BEGIN + y)) || ((hcount >= H_BEGIN + y - 5) && (hcount <= H_BEGIN + y + 5) && (vcount == V_BEGIN + x)));
        
    	assign vgaRed = (de && cross) ? color[3:0] : 0;
    	assign vgaGreen = (de && cross) ? color[7:4] : 0;
    	assign vgaBlue = (de && cross) ? color[11:8] : 0;
    
    endmodule
    
    module counter(
    	input clk,             
    	input rst,             
    	input [15:0] range,
    	output reg [15:0] value
    );
    
        always @(posedge clk or posedge rst)
        begin
            if (rst) value <= 0;
            else if (value == range - 1) value <= 0;
            else value <= value + 1;
        end
    
    endmodule
    
    ```

* ##### 实验总结

  * 本次实验主要学习了VGA显示原理，并利用RAM完成对显示数据的读取与保存。细节方面，学习了有：

    * VGA显示接口信号，显示区域和标准定时参数，显示频率；
    * RAM的IP核实例化
  * 主要反思有：
    * 赋给RAM的写时钟不能太快，否则写入的数据和地址会抖动；

    * VGA显示时不同分辨率的定时参数和时钟频率不一样，要注意区分；

    * 时钟分频时新时钟要用寄存器变量产生高/低电平，不能用组合逻辑。

      

* 附：仿真文件代码

  ```verilog
  `timescale 1ns / 1ps
  
  module PCU_tb();
      reg clk;
      reg rst;
      reg [3:0]RED;
      reg [3:0]GRN;
      reg [3:0]BLU;
      reg draw;
      reg [3:0]dir;
      
      wire [7:0]x;
      wire [7:0]y;
      
      wire [3:0]VGA_R;
      wire [3:0]VGA_G;
      wire [3:0]VGA_B;
      wire VGA_VS;
      wire VGA_HS;
      
      PCU DUT(
          .x(x),
          .y(y),
          .clk(clk), 
          .rst(rst), 
          .RED(RED), 
          .GRN(GRN), 
          .BLU(BLU), 
          .draw(draw), 
          .dir(dir), 
          .VGA_R(VGA_R), 
          .VGA_B(VGA_B), 
          .VGA_G(VGA_G), 
          .VGA_HS(VGA_HS), 
          .VGA_VS(VGA_VS)
          );
      
      initial clk = 0;
      always #1 clk = ~clk;
      
      initial
      begin
          #20 rst = 0;
              {RED,GRN,BLU} = 12'b0000_1111_0000;
              draw = 1;
          #20 rst = 1;
          #50 rst = 0;
          #50 dir = 4'b0001;
          #15 dir = 4'b0000;
          #50 dir = 4'b0010;
          #15 dir = 4'b0000;
          #50 dir = 4'b0100;
          #15 dir = 4'b0000;
          #50 dir = 4'b1000;
          #15 dir = 4'b0000;
          #50 dir = 4'b0001;
          #15 dir = 4'b0000;
          #50 dir = 4'b1000;
          #15 dir = 4'b0000;
          #50 dir = 4'b0100;
          #15 dir = 4'b0000;
          #50 dir = 4'b0010;
          #15 dir = 4'b0000;
      end
          
  endmodule
  ```
