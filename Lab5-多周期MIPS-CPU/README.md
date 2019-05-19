## <center> 实验报告 </center>

​	<center> 实验题目：多周期MIPS-CPU&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日期：2019年5月17日 </center>

​	<center> 姓名：张焰舒&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;学号：PB17081544&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;成绩：————</center>

* ##### 实验要求

  * 设计实现多周期MIPS-CPU，可执行如下指令：

    * add,sub,and,or,xor,nor,slt
    * addi,andi,ori,xori,slti
    * lw,sw
    * beq,bne,j

  * 设计实现调试和显示单元DDU(Debug and Display Unit)，满足如下要求：

    * 控制CPU运行方式：
      * cont = 1时CPU连续执行指令
      * cont = 0时，每按动step一次，run输出维持一个时钟周期的脉冲，控制CPU执行一条指令
    * 查看CPU运行状态：
      * mem：1-查看MEM；0-查看RF
      * inc/dec：增加或减小待查看RF/MEM的地址addr
      * reg_data/mem_data：从RF/MEM读取的数据
      * 8位数码管显示RF/MEM的一个32位数据
      * 16位LED指示RF/MEM的地址和PC的值

  * 完成MIPS-CPU和DDU的逻辑设计和下载测试

  * 查看电路性能和资源使用情况

  * 检查仿真结果是否正确

    

* ##### 实验内容

  * 总控制单元与数据通路电路图

    * CPU：MIPS-CPU

    * MEM：DataMem和InstructionMem合并，调用IP核 Distributed Memory Generator 中的 Dual Port RAM 实现

    * DDU：调试和显示单元

      ![1557844820689](assets/1557844820689.png)

    

  * CPU

    * 数据通路

      ![1557844870050](assets/1557844870050.png)

    

    * 控制单元状态机

      ![1557844951372](assets/1557844951372.png)

    * 代码(仅顶层，部分模块见末尾)

      ```verilog
      module CPU(
          input clk,
          input rst,
          input [31:0]DDU_addr,
          input run,
          output [15:0]immediate,
          output [31:0]ReadData1,
          output [31:0]ReadData2,
          output [31:0]RegWriteData,
          output [31:0]MemDataOut,
          output [31:0]pc,
          output [31:0]ALUresult,
          output [3:0]state,
          output [31:0]newAddress,
          output [31:0]DDU_mem_data,
          output [31:0]DDU_reg_data,
          output [5:0]op,
          output [4:0]rs,
          output [4:0]rt,
          output [4:0]rd,
          output [4:0]shamt,
          output [5:0]func,
          output MemWrite,
          output [31:0]BDRData 
          );
      
          wire RegDst;
          wire CondSrc;
          wire RegWrite;
          wire ALUSrcA;
          wire MemRead;
          wire MemtoReg;
          wire IorD;
          wire IRWrite;
          wire PCWrite;
          wire PCWriteCond;
          wire [1:0]ALUOp;
          wire [1:0]ALUSrcB;
          wire [1:0]PCSrc;
          wire zero;
          wire [31:0]ALUOutData;
          wire [31:0]MemAddress;
          wire PCWre;
          wire [31:0]MemWriteData;
          wire [31:0]MDRData;
          wire [4:0]WriteReg;
          wire [31:0]SignExtendData;
          wire [31:0]SignExtendDatal2;
          wire [31:0]ADRData;
          wire [31:0]ALUA;
          wire [31:0]ALUB;
          wire [3:0]ALUSel;
          wire [25:0]instAddress;
          wire [31:0]JumpAddress;
          wire zerosel;
          wire andout;
          wire orout;
      
          and ad1(andout,zerosel,PCWriteCond);
          or o1(orout,andout,PCWrite);
          and ad2(PCWre,run,orout);
          
          assign instAddress = {rs,rt,rd,shamt,func};
          assign JumpAddress = {currentAddress[31:28],instAddress,2'b00};
      
      	assign immediate = {rd,shamt,func};
          assign SignExtendDatal2 = SignExtendData << 2;
      
          PC pc(
              .clk(clk),
              .rst(rst),
              .PCWre(PCWre),
              .newAddress(newAddress),
              .currentAddress(currentAddress),
              .beginAddress(0)
              );
      
          ControlUnit ctl(
              .clk(clk),
              .state(state),
              .CondSrc(CondSrc),
              .rst(rst),
              .opCode(op),
              .PCWrite(PCWrite),
              .ALUSrcB(ALUSrcB),
              .ALUSrcA(ALUSrcA),
              .RegWrite(RegWrite),
              .RegDst(RegDst),
              .MemRead(MemRead),
              .MemWrite(MemWrite),
              .MemtoReg(MemtoReg),
              .IorD(IorD),
              .IRWrite(IRWrite),
              .PCWriteCond(PCWriteCond),
              .PCSrc(PCSrc),
              .ALUOp(ALUOp)
              );
          
          IR ir(
              .MemData(MemDataOut),
              .IRWrite(IRWrite),
              .clk(clk),
              .instOP(op),
              .instRS(rs),
              .instRT(rt),
              .instRD(rd),
              .instSHAMT(shamt),
              .instFUNC(func)
              );
      
          dist_mem_gen_0 mem(
              .a(MemAddress[9:2]),
              .we(MemWrite),
              .d(BDRData),
              .spo(MemDataOut),
              .dpra(DDU_addr[7:0]),
              .dpo(DDU_mem_data),
              .clk(clk)
              );
      
          MDR mdr(
              .clk(clk),
              .i_data(MemDataOut),
              .o_data(MDRData)
              );
      
          RegFile RF(
              .clk(clk),
              .ReadReg1(rs),
              .ReadReg2(rt),
              .WriteReg(WriteReg),
              .WriteData(RegWriteData),
              .RegWrite(RegWrite),
              .ReadData1(ReadData1),
              .ReadData2(ReadData2),
              .DDU_addr(DDU_addr),
              .DDU_reg_data(DDU_reg_data)
              );
      
          SignExtend SE(
              .i_num(immediate),
              .o_num(SignExtendData),
              .op(op)
              );
      
          ADR AR(
              .clk(clk),
              .i_data(ReadData1),
              .o_data(ADRData)
              );
      
          BDR BR(
              .clk(clk),
              .i_data(ReadData2),
              .o_data(BDRData)
              );
      
          ALU alu(
              .A(ALUA),
              .B(ALUB),
              .ALUSel(ALUSel),
              .zero(zero),
              .result(result)
              );
      
          ALUControl acl(
              .ALUOp(ALUOp),
              .ALUSel(ALUSel),
              .funcCode(func),
              .opCode(op)
              );
      
          ALUOut aou(
              .clk(clk),
              .i_data(result),
              .o_data(ALUOutData)
              );
      
          MUX mux1(
              .in0(currentAddress),
              .in1(ALUOutData),
              .sel({0,IorD}),
              .out(MemAddress)
              );
      
          MUX mux2(
              .in0(ALUOutData),
              .in1(MDRData),
              .sel({0,MemtoReg}),
              .out(RegWriteData)
              );
      
          MUX mux3(
              .in0(rt),
              .in1(rd),
              .sel({0,RegDst}),
              .out(WriteReg)
              );
      
          MUX mux4(
              .in0(currentAddress),
              .in1(ADRData),
              .sel({0,ALUSrcA}),
              .out(ALUA)
              );
      
          MUX mux5(
              .in0(BDRData),
              .in1(32'd4),
              .in2(SignExtendData),
              .in3(SignExtendDatal2),
              .sel(ALUSrcB),
              .out(ALUB)
              );
          
          MUX mux6(
              .in0(result),
              .in1(ALUOutData),
              .in2(JumpAddress),
              .sel(PCSrc),
              .out(newAddress)
              );
          
          MUX mux7(
              .in0(zero),
              .in1(~zero),
              .sel({0,CondSrc}),
              .out(zerosel)
              );
      
      endmodule
      ```

      

  * DDU

    ``` verilog
    module DDU(
        input   cont,
        input   step,
        input   mem,
        input   inc,
        input   dec,
        input   [7:0]pc,
        input   clk, 
        input   rst,
        output  [7:0]addr,
        output  [7:0]addr_led,
        output  [7:0]pc_led,
        input   [31:0]reg_data,
        input   [31:0]mem_data,
        output  [7:0]an,
        output  [6:0]seg,
        output  reg run,
        input   clk2			//clk_100MHz
        );
        
        wire    [31:0]d;
        reg     [3:0]data;
        
        reg    	[7:0]addr_rf, addr_mem;
        reg     [15:0]display;
        
        /* state to control run */
        reg    	[3:0]rs, next_rs;
        
        always @(negedge clk2 or posedge rst)
        begin
            if(rst)
                rs <= 0;
            else
                rs <= next_rs;
        end
               
        always @(*)
        begin
           case(rs)
               0:begin
                   if(cont == 1)
                       next_rs = 0;
                   else
                       next_rs = 1;
               end
               1:begin
                   if(cont == 1)
                       next_rs = 0;
                   else if(step == 0)
                       next_rs = 1;
                   else
                       next_rs = 2;
               end
               2:next_rs = 3;
               3:begin
                   if(step == 1)
                       next_rs = 3;
                   else
                       next_rs = 1;
               end
               default:next_rs = 0;
           endcase
        end               
        
        always @(rs)
        begin
           case(rs)
               0:run = 1;
               1:run = 0;
               2:run = 1;
               3:run = 0;
               default:run = 1;
           endcase
        end
    
        assign  d = (mem == 1) ? mem_data : reg_data;
        assign  pc_led = pc[7:0];
        assign  addr_led = addr;
        assign  an = display[7:0];
        assign  seg = display[15:9];
        
        assign  addr = (mem == 1) ? addr_mem[7:0] : addr_rf[7:0];
    	
        /* state to control an */
        reg     [3:0] state;
        
        /* ctrl is state to control addr */
        reg     [2:0] ctrl;
        reg     [2:0] next_ctrl;
        
        parameter   s0 = 4'd0, 
                    s1 = 4'd1, 
                    s2 = 4'd2, 
                    s3 = 4'd3,
                    s4 = 4'd4, 
                    s5 = 4'd5, 
                    s6 = 4'd6, 
                    s7 = 4'd7,
                    start = 4'd8;
        
        integer k = 0;
        
        always @(posedge clk2 or posedge rst)
        begin
            if(rst)
                ctrl <= 0;
            else
                ctrl <= next_ctrl;
        end
           
        always @(*)
        begin
            case(ctrl)
                0:case ({inc,dec})
                    2'b10:next_ctrl = 1;
                    2'b01:next_ctrl = 2;
                    default :next_ctrl = 0;
                endcase
                1:next_ctrl = 3;
                2:next_ctrl = 4;
                3:case ({inc,dec})
                    2'b00:next_ctrl <= 0;
                    default :next_ctrl <= 3;
                endcase
                4:case ({inc,dec})
                    2'b00:next_ctrl <= 0;
                    default :next_ctrl <= 4;
                endcase
                default:next_ctrl = 0;
            endcase
        end            
        
        always @(posedge clk2 or posedge rst)
        begin
            if(rst)
            begin
                addr_rf <= 0;
                addr_mem <= 0;
            end
            else
                case(ctrl)
                    1:begin
                        addr_mem <= (mem) ? addr_mem + 1'b1 : addr_mem;
                        addr_rf <= (mem == 0) ? addr_rf + 1'b1 : addr_rf;
                    end
                    2:begin
                        addr_mem <= (mem) ? addr_mem - 1'b1 : addr_mem;
                        addr_rf <= (mem == 0) ? addr_rf - 1'b1 : addr_rf;
                    end
                    default:;
                endcase
        end
    
        always @(posedge clk or posedge rst)
        begin
            if(rst)
            begin
                k <= 0;
                state <= s0;
            end
            else
            begin
                k <= k + 1;
                if(k < 25000)
                    state <= s0;
                else if(k < 50000)
                    state <= s1;
                else if(k < 75000)
                    state <= s2;
                else if(k < 100000)
                    state <= s3;
                else if(k < 125000)
                    state <= s4;
                else if(k < 150000)
                    state <= s5;
                else if(k < 175000)
                    state <= s6;
                else if(k < 200000)
                    state <= s7;
                else if(k >= 200000)
                    k <= 0;
            end
        end
        
        always @(*)
        begin
            case(state)
                s0: 
                begin
                    display[7:0] = 8'b1111_1110;
                    data = d[3:0];
                    end
                s1: 
                begin
                    display[7:0] = 8'b1111_1101;
                    data = d[7:4];
                    end
                s2: 
                begin
                    display[7:0] = 8'b1111_1011;
                    data = d[11:8];
                    end
                s3: 
                begin
                    display[7:0] = 8'b1111_0111;
                    data = d[15:12];
                    end
                s4: 
                begin
                    display[7:0] = 8'b1110_1111;
                    data = d[19:16];
                    end
                s5: 
                begin
                    display[7:0] = 8'b1101_1111;
                    data = d[23:20];
                    end
                s6: 
                begin
                    display[7:0] = 8'b1011_1111;
                    data = d[27:24];
                    end
                s7: 
                begin
                    display[7:0] = 8'b0111_1111;
                    data = d[31:28];
                    end
                default:;
            endcase
        end
       
        always @(state)
        begin
            display[8] = 1;
            case(data)
                4'h0: display[15:9] = 7'b1000_000;
                4'h1: display[15:9] = 7'b1111_001;
                4'h2: display[15:9] = 7'b0100_100;
                4'h3: display[15:9] = 7'b0110_000;
                4'h4: display[15:9] = 7'b0011_001;
                4'h5: display[15:9] = 7'b0010_010;
                4'h6: display[15:9] = 7'b0000_010;
                4'h7: display[15:9] = 7'b1111_000;
                4'h8: display[15:9] = 7'b0000_000;
                4'h9: display[15:9] = 7'b0010_000;
                4'ha: display[15:9] = 7'b0001_000;
                4'hb: display[15:9] = 7'b0000_011;
                4'hc: display[15:9] = 7'b1000_110;
                4'hd: display[15:9] = 7'b0100_001;
                4'he: display[15:9] = 7'b0000_110;
                4'hf: display[15:9] = 7'b0001_110;
                default:;
            endcase
        end
                
    endmodule
    ```

  * CPU仿真（仿真代码附于文章末尾）

    ![2019-05-14](assets/2019-05-14.png)

    

  * 电路性能和资源使用情况

    ![2019-05-14 (assets/2019-05-14 (7).png)](../../OneDrive/Pictures/屏幕快照/COD-lab5/2019-05-14 (7).png)

    ![2019-05-14 (assets/2019-05-14 (6).png)](../../OneDrive/Pictures/屏幕快照/COD-lab5/2019-05-14 (6).png)

    

  * 下载

    ![IMG_20190514_225322](assets/IMG_20190514_225322.jpg)




* ##### 实验总结

  * 本次实验可以说是目前为止收获最多的硬件相关实验，多周期CPU设计不仅综合了前几次实验的结果，还考验对于多周期CPU原理与结构、不同类型MIPS指令的执行流程、控制单元不同阶段对应的不同信号以及存储与计算之间的相互调用的熟悉程度，本次实验大大加深了本人对于多周期MIPS-CPU的熟悉与理解。细节方面，学习了有：

    * 不同状态下控制单元产生的信号变化及其作用；
    * 加强了对于时序逻辑和组合逻辑并存的复杂情况的分析能力；
    * RAM的IP核的初始化
    * 编译预处理操作，如宏定义\`define和"文件包含"处理 `include
  * 主要反思有：
    * 状态机最好写三段式，并且一定要规范，比如三个always块对应不同的时序控制变量；

    * 控制单元状态机状态改变时有些参数要复位，比如IRWrite在译码阶段要重置为0；

    * 时钟分频时新时钟要用寄存器变量产生高/低电平，不能用组合逻辑。

      

* 附：仿真文件代码

  ```verilog
  `timescale 1ns / 1ps
  
  module CPU_tb();
  	reg clk;
      reg rst;
      reg [31:0]DDU_addr;
      reg run;
      wire [5:0]op;
      wire [4:0]rs;
      wire [4:0]rt;
      wire [4:0]rd;
      wire [4:0]shamt;
      wire [5:0]func;
      wire [15:0]immediate;
      wire [31:0]ReadData1;
      wire [31:0]ReadData2;
      wire [31:0]RegWriteData;
      wire [31:0]MemDataOut;
      wire [31:0]currentAddress;
      wire [31:0]result;
      wire [3:0]state;
      wire [31:0]newAddress;
      wire [31:0]DDU_mem_data;
      wire [31:0]DDU_reg_data;
      wire MemWrite;
      wire [31:0]BDRData;
  
      integer k = 0;
  
      CPU DUT(
      	.clk           (clk),
      	.rst           (rst),
      	.DDU_addr      (DDU_addr),
      	.op            (op),
      	.rs            (rs),
      	.rt            (rt),
      	.rd            (rd),
      	.shamt         (shamt),
      	.func          (func),
      	.immediate     (immediate),
      	.ReadData1     (ReadData1),
      	.ReadData2     (ReadData2),
      	.RegWriteData  (RegWriteData),
      	.MemDataOut    (MemDataOut),
      	.currentAddress(currentAddress),
      	.result        (result),
      	.state         (state),
      	.newAddress    (newAddress),
      	.DDU_mem_data  (DDU_mem_data),
      	.DDU_reg_data  (DDU_reg_data),
      	.run           (run),
      	.MemWrite      (MemWrite),
      	.BDRData       (BDRData)
      	);
  
      initial clk = 0;
      always #5 clk = ~clk;
  
      initial
      begin
      	run = 1;
      	rst = 0;
      	#20 rst = 1;
      	#20 rst = 0;
      end
  
  endmodule
  ```

* ControlUnit

  ```verilog
  
  `include"defines.v"
  
  module ControlUnit(
      input clk,
      input rst,
      input [5:0]opCode,
      output reg PCWrite,
      output reg [1:0]ALUSrcB,
      output reg ALUSrcA,
      output reg RegWrite,
      output reg RegDst,
      output reg MemRead,
      output reg MemWrite,
      output reg MemtoReg,
      output reg IorD,
      output reg IRWrite,
      output reg PCWriteCond,
      output reg[1:0]PCSrc,
      output reg[1:0]ALUOp,
      output reg CondSrc,
      output reg [3:0]state
      
      );
      
      reg [3:0]next_state;
      
      parameter FETCH_INST=4'b0000;
      parameter DECODE=4'b0001;
      parameter CALCULATE_ADDR=4'b0010;
      parameter LW_ACCESS_MEM=4'b0011;
      parameter SW_ACCESS_MEM=4'b0101;
      parameter ACCESS_MEM_FIN=4'b0100;
      parameter R_FIN=4'b0111;
      parameter EXECUTION=4'b0110;
      parameter BRANCH_FIN=4'b1000;
      parameter JUMP_FIN=4'b1001;
      parameter N_BRANCH_FIN=4'b1010;
      parameter RI_EXECUTION=4'b1011;
      parameter RI_FIN=4'b1100;
      
      always@(posedge clk or posedge rst)
      begin
          if(rst)
              state <= FETCH_INST;
          else 
              state <= next_state;
      end
      
      always@(opCode,state)
      begin
          case(state)
              FETCH_INST:next_state=DECODE;
              DECODE:begin
                  case(opCode)
                      `EXE_SW:    next_state = CALCULATE_ADDR;
                      `EXE_LW:    next_state = CALCULATE_ADDR;
                      `EXE_BEQ:   next_state = BRANCH_FIN;
                      `EXE_J:     next_state = JUMP_FIN;
                      `EXE_BNE:   next_state = N_BRANCH_FIN;
                      `EXE_ADDI:  next_state = RI_EXECUTION;
                      `EXE_ANDI:  next_state = RI_EXECUTION;
                      `EXE_ORI:   next_state = RI_EXECUTION;
                      `EXE_XORI:  next_state = RI_EXECUTION;
                      `EXE_SLTI:  next_state = RI_EXECUTION;
                      6'b000000:  next_state = EXECUTION;
                      default:    next_state = FETCH_INST;
                  endcase
              end
              CALCULATE_ADDR:begin
                  case(opCode)
                      `EXE_SW:    next_state = SW_ACCESS_MEM;
                      `EXE_LW:    next_state = LW_ACCESS_MEM;
                      default:    next_state = FETCH_INST;
                  endcase
              end
              LW_ACCESS_MEM:  next_state = ACCESS_MEM_FIN;
              SW_ACCESS_MEM:  next_state = FETCH_INST;
              ACCESS_MEM_FIN: next_state = FETCH_INST;
              EXECUTION:      next_state = R_FIN;
              R_FIN:          next_state = FETCH_INST;
              RI_EXECUTION:   next_state = RI_FIN;
              RI_FIN:         next_state = FETCH_INST;
              BRANCH_FIN:     next_state = FETCH_INST;
              N_BRANCH_FIN:   next_state = FETCH_INST;
              JUMP_FIN:       next_state = FETCH_INST;
              default:        next_state = FETCH_INST;
          endcase
      end
      
      always@(state)
      begin
          case (state)
              FETCH_INST:begin
                  MemRead     = 1'b1;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b0;
                  IRWrite     = 1'b1;
                  ALUSrcB     = 2'b01;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b1;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              DECODE:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b11;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              CALCULATE_ADDR:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b1;//
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b10;//
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              LW_ACCESS_MEM:begin
                  MemRead     = 1'b1;//
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b1;//
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              SW_ACCESS_MEM:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b1;//
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b1;//
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              ACCESS_MEM_FIN:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b1;//
                  MemtoReg    = 1'b1;//
                  CondSrc     = 1'b0;
              end
              EXECUTION:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b1;//
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b10;//
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              R_FIN:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b1;//
                  RegWrite    = 1'b1;//
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              RI_EXECUTION:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b1;//
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b10;//
                  ALUOp       = 2'b11;//
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              RI_FIN:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b1;//
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              BRANCH_FIN:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b1;//
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b01;//
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b01;//
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b1;//
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              N_BRANCH_FIN:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b1;//
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b01;//
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b01;//
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b1;//
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b1;//
              end
              JUMP_FIN:begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b1;//
                  PCSrc       = 2'b10;//
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
              default : begin
                  MemRead     = 1'b0;
                  ALUSrcA     = 1'b0;
                  IorD        = 1'b0;
                  IRWrite     = 1'b0;
                  ALUSrcB     = 2'b00;
                  ALUOp       = 2'b00;
                  PCWrite     = 1'b0;
                  PCSrc       = 2'b00;
                  MemWrite    = 1'b0;
                  PCWriteCond = 1'b0;
                  RegDst      = 1'b0;
                  RegWrite    = 1'b0;
                  MemtoReg    = 1'b0;
                  CondSrc     = 1'b0;
              end
          endcase
      end
      
  endmodule
  ```

  

* ALUControl

  ```verilog
  `include"defines.v"
  
  module ALUControl(
      input [1:0]ALUOp,
      output reg[3:0]ALUSel,
      input [5:0]funcCode,
      input [5:0]opCode
      );
  
      always@(*)
      begin
          if(ALUOp == 2'b00)
              ALUSel = 4'b0010;
          else if(ALUOp == 2'b01)
              ALUSel = 4'b0110;
          else if(ALUOp == 2'b11)begin
              case(opCode)
                  `EXE_ADDI:  ALUSel = 4'b0010;
                  `EXE_ANDI:  ALUSel = 4'b0000;
                  `EXE_ORI:   ALUSel = 4'b0001;
                  `EXE_XORI:  ALUSel = 4'b1100;
                  `EXE_SLTI:  ALUSel = 4'b0111;
                  default:    ALUSel = 4'b0010;
              endcase
          end
          else begin
              case(funcCode)
                  `EXE_FUNC_ADD:  ALUSel = 4'b0010;
                  `EXE_FUNC_SUB:  ALUSel = 4'b0110;
                  `EXE_FUNC_AND:  ALUSel = 4'b0000;
                  `EXE_FUNC_OR:   ALUSel = 4'b0001;
                  `EXE_FUNC_SLT:  ALUSel = 4'b0111;
                  `EXE_FUNC_XOR:  ALUSel = 4'b1100;
                  `EXE_FUNC_NOR:  ALUSel = 4'b0011;
                  default:        ALUSel = 4'b0010;
              endcase
          end
      end
      
  endmodule
  ```
