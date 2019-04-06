## <center> 实验报告 </center>

​	<center> 实验题目：ALU与寄存器&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日期：2019年3月22日 </center>

​	<center> 姓名：张焰舒&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;学号：PB17081544&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;成绩：————</center>

- ##### 实验目的

  - 编写一个算术逻辑单元（ALU），完成仿真和下载测试

  - 利用ALU求给定两个初始数的斐波那契数列（结果从同一端口分时输出），完成仿真和下载测试

    

- ##### 实验内容

  - 算术逻辑单元（ALU）

    - 代码

      ```verilog
      module ALU(OP,A,B,F,ZF,CF,OF);
          parameter SIZE = 5;//运算位数
          input	[2:0] OP;//运算操作
          input 	[SIZE:0] A;//左运算数
          input 	[SIZE:0] B;//右运算数
          output 	reg [SIZE:0] F;//运算结果
          output  reg	ZF, //0标志位
                  	CF, //进借位标志位
                  	OF; //溢出标志位
      
          reg C;//C为最高位进位
          always@(*)
          begin
              C=0;
              case(OP)
                  3'b000:F=A&B;     //按位与
                  3'b001:F=A|B;     //按位或
                  3'b010:F=A^B;     //按位异或
                  3'b011:F=~(A|B);  //按位或非
                  3'b100:{C,F}=A+B; //加法
                  3'b101:{C,F}=A-B; //减法
                  3'b110:F=B<<A	  //B左移A位
              endcase
              
              ZF = F==0;//F全为0，则ZF=1
              CF = C; //进位借位标志
              OF = A[SIZE]^B[SIZE]^F[SIZE]^C;//溢出标志公式
      
          end     
      endmodule
      ```      

  - 斐波那契数列

    - 代码

      ```verilog
      module fib(
                 input [5:0]  A,B,
                 input clk, rst_n,
                 output [5:0] F
                 );
         reg [5:0]            r1, r2, r3;
      
         parameter op = 3'b100;
      
         ALU myalu2(.OP(op), .A(r1), .B(r2), .F(F));
        
         initial 
         begin
              r1 = A;
              r2 = B;
         end
      
         always@(posedge clk or posedge rst_n)
           begin
              if(rst_n)
                begin
                   r1 <= A;
                   r2 <= B;
                end
              else
                begin
                   r1 = r2;
                   r2 = F;           
                end
           end 
         
      endmodule // fib
      ```    

  - 累加器（ACC）

    - 代码

      ```verilog
      module ACC(
          input [3:0] in,
          input en,rst_n,clk,
          output reg [3:0] out
          );
          
          reg [3:0] r1,r2;
          wire [3:0] o;
          parameter op = 3'b100;
          
          ALU add (
              .A(r1),
              .B(r2),
              .F(o),
              .OP(op)
              );
          
          always @(posedge clk or posedge rst_n)
          begin
              if(rst_n)
              begin
                  r1 = 0;
                  r2 = in;
                  out = 0;
              end
              else if(en)
              begin
                  r1 = out;
                  r2 = in;
                  out = o;
              end
          end
               
      endmodule
      ```      

- ##### 实验总结

  - 本次实验主要学习了ALU的原理、功能与设计方法，以及寄存器的原理和设计方法，设计并实现了具有基本功能的ALU，并应用ALU设计并实现了4位斐波那契数列计算器。细节方面，学习了有：
    - 溢出与借/进位的区别，即溢出是运算结果超出了补码的表示范围，而借/进位是无符号数在加减过程中更高位的变化；
    - 参数化模块的方法以及传递子模块中定义参数的方法；
  - 主要反思有：
    - 实验前要仔细阅读实验要求，避免实验结果满足要求但实现方法不一样导致重做；
    - 用输入信号reset初始化寄存器，而不是用initial，initial仅用于仿真，对下载无用；
    - 理解每一步的意义，并寻求效率更高的方法，而不是单纯的实现功能。

