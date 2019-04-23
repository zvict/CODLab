## <center> 实验报告 </center>

实验题目：寄存器堆与计数器

* ##### 实验目的

  * 设计寄存器堆：设计并实现一个寄存器堆（Reg File），仿真并下载测试，同时查看电路性能和资源使用情况。

  * 设计计数器：设计并实现一个计数器（Counter），查看电路性能和资源使用情况。

  * 设计FIFO循环队列：基于寄存器堆、计数器和适当逻辑实现一个最大长度为8的FIFO循环队列，仿真并下载测试。

    

* ##### 实验内容

  * 寄存器堆（Reg File）

    * 具体要求

      2个异步读端口，1个同步写端口


    * 代码

      ``` verilog
      module RegFile(clk,rst,we,ra0,ra1,wa,wd,rd0,rd1);
          parameter ADDR = 5;	//寄存器编码/地址位宽
          parameter NUMB = 16;//寄存器个数
          parameter SIZE = 5;	//寄存器数据位宽
          
          input clk;			//100MHz			
          input rst;
          input we;
          input [ADDR:0]ra0;
          input [ADDR:0]ra1;
          input [ADDR:0]wa;
          input [SIZE:0]wd;
          
          output [SIZE:0]rd0;
          output [SIZE:0]rd1;
          
          reg [SIZE:0]REG_Files[0:NUMB-1];
          integer i;
              
          always@(posedge clk or posedge rst)
          begin
              if(rst)
                  for(i = 0;i < NUMB;i = i + 1) 
                      REG_Files[i] <= 0;
              else
                  if(~we) 
                      REG_Files[wa] <= wd;
          end
          
          assign rd0 = REG_Files[ra0];
          assign rd1 = REG_Files[ra1];
              
      endmodule
      
      ```
      

  * 计数器（Counter）

    * 具体要求

      同步装数，异步清零

    * 代码

      ``` verilog
      module CNT(d,pe,ce,rst,clk,q);
          parameter SIZE = 4;
          parameter MAX = 9;
          
          input   [SIZE:1] d;
          input   pe;				//装数使能
          input   ce;				//计数使能
          input   rst;			//异步清零
          input   clk;
          output  reg [SIZE:1] q;
          
          always @(posedge clk or posedge rst)
          begin
              if(rst)
                  q <= 0;
              else if(pe)
                  q <= d;
              else if(ce)
              begin
                  if(q == MAX)
                      q <= 0;
                  else
                      q <= q + 1;
              end
          end
          
      endmodule
      ```

  * 长度为8的FIFO循环队列

    * 具体要求

      * en_out/en_in：出/入队使能，一次有效仅允许操作一项数据

      * out，in：出/入队数据

      * full，empty：队列空/满，空/满时忽略出/入队操作

      * display：8个数码管的控制信号，显示队列状态

    * 代码分析

      * 输入/输出和辅助变量

        * 为保证一次使能只有一次入/出队，设置ready和over状态，同时设置数据缓冲避免冲突
        * 通过区分满/空前一次的状态区分满/空

        ``` verilog
            input   en_out,en_in,clk,rst;
            
            input   [3:0] in_data;
            output  [3:0] out_data;
            output  [15:0] display;
            
        	/* 满/空标志 */
            output  reg nfull,nempty;					
            
            /* RF参数 */
            wire    wr;    
            wire    [3:0] in_d, out_d;  
        	
        	/* 输入输出数据缓冲 */
        	reg     [3:0] in_data_buf, out_data_buf;
            
        	/* 读/写指针 */
            reg     [5:0] fifo_wp, fifo_rp;
            reg     [5:0] fifo_wp_next, fifo_rp_next;
            
        	/* 满/空前状态 */
            reg     near_full, near_empty;
            
            reg   	[3:0] state;
            
            /* 空满标志 */
            reg   [`SRAM_SIZE - 1:0] flag;
            
        	/* display参数 */
            wire [5:0] dis_addr;
            wire [4:0] dis_data;
            
        	/* 队列的7个状态 */
            parameter   idle = 'b0000,
                        read_ready = 'b0100,
                        read = 'b0101,
                        read_over = 'b0111,
                        write_ready = 'b1000,
                        write = 'b1001,
                        write_over = 'b1011;
        ```

      * 状态转换

        ``` verilog
        	always @(posedge clk or posedge rst)
            begin
                if(rst)										//初始化
                begin
                    state <= idle;
                    flag <= 0;
                    end
                else
                    case(state)
                        idle:
                            if(en_in == 0 && nfull)
                                state <= write_ready;
                            else if(en_out == 0 && nempty)
                                state <= read_ready;
                            else
                                state <= idle;
                                
                        read_ready:
                            state <= read;
                        
                        read:
                            if(en_out == 1)
                                state <= read_over;
                            else
                                state <= read;
                        
                        read_over:
                            state <= idle;
                        
                        write_ready:
                            state <= write;
                        
                        write:
                            if(en_in == 1)
                                state <= write_over;
                            else
                                state <= write;
                                
                        write_over:
                            state <= idle;
                            
                        default:state <= idle;
                    endcase
            end
        ```

      * 读/写指针转换

        ```verilog
        	always @(posedge clk or posedge rst)
                if(rst)
                    fifo_rp <= 0;
                else if(state == read_over)
                    fifo_rp <= fifo_rp_next;
            
            always @(fifo_rp)
                if(fifo_rp == `SRAM_SIZE - 1)
                    fifo_rp_next = 0;
                else
                    fifo_rp_next = fifo_rp + 1;
            
            always @(posedge clk or posedge rst)
                if(rst)
                    fifo_wp <= 0;
                else if(state == write_over)
                    fifo_wp <= fifo_wp_next;
            
            always @(fifo_wp)
                if(fifo_wp == `SRAM_SIZE - 1)
                    fifo_wp_next = 0;
                else
                    fifo_wp_next = fifo_wp + 1;
        ```

      * 空/满判断

        * 高电平为空/满

        ```verilog
        	always @(posedge clk or posedge rst)
                if(rst)
                    near_empty <= 1'b0;
                else if(fifo_wp == fifo_rp_next)
                    near_empty <= 1'b1;
                else
                    near_empty <= 1'b0;
            
            always @(posedge clk or posedge rst)
                if(rst)
                    nempty <= 1'b0;
                else if(near_empty && state == read)
                    nempty <= 1'b0;
                else if(state == write)
                    nempty <= 1'b1;
                
            always @(posedge clk or posedge rst)
                if(rst)
                    near_full <= 1'b0;
                else if(fifo_rp == fifo_wp_next)
                    near_full <= 1'b1;
                else
                    near_full <= 1'b0;
                    
            always @(posedge clk or posedge rst)
                if(rst)
                    nfull <= 1'b1;
                else if(near_full && state == write)
                    nfull <= 1'b0;
                else if(state == read)
                    nfull <= 1'b1;
        ```

      * 数据输入/输出

        ```verilog
        	/* 写使能（低电平有效） */
        	assign wr = (state == write) ? en_in : 1'b1;
        
        	/* 输入RF数据与输出数据 */
        	assign in_d = (state[3]) ? in_data_buf : 4'b0000;
        	assign out_data = (state[2]) ? out_data_buf : 4'b0000;
        
        	/* 缓冲区读/写 */
        	always @(posedge clk)
                if(~en_in)
                begin
                    in_data_buf <= in_data;
                    flag[fifo_wp] <= 1'b1;
            end
        
        	always @(posedge clk)
                if(state == read)
                begin
                    out_data_buf <= out_d;
                    flag[fifo_rp] <= 0;
            end
        ```


* ##### 实验总结

  * 本次实验主要学习了寄存器堆和FIFO队列的原理、功能与设计方法，熟悉了计数器和7段数码管显示的设计方法，并应用寄存器堆和状态机设计并实现了FIFO队列。细节方面，学习了有：

    * FIFO队列定义，原理和出/入队控制，队满/空判断方法；
    * 7段数码管的显示控制和不同数码管的分频显示
  * 主要反思有：
    * 一个always语句中最好只对一个变量做修改，同一寄存器变量不能在多个always块中赋值；
    * 用输入信号reset初始化队列，而不是用initial，initial仅用于仿真，对下载无用；
    * 实验中可以用一个计数器或者队列空/满前一状态的不同来判断空/满，本人用的是后一方法；
    * 时钟分频时新时钟要用寄存器变量产生高/低电平，不能用组合逻辑。

