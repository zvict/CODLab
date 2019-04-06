## <center> 实验报告 </center>

​	<center> 实验题目：数据通路与状态机&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日期：2019年3月29日 </center>


- ##### 实验目的

  - 设计排序器：应用数据通路与状态机并调用ALU实现四个四位无符号数的排序，仿真并下载

  - 设计除法器：应用数据通路与状态机并调用ALU实现四位无符号数的除法运算，仿真并下载

    

- ##### 实验内容

  - 排序器（SRT）

    - 排序原理

      冒泡排序

      

    - 代码

      ```verilog
      module SRT(clk,rst,done,x0,x1,x2,x3,s0,s1,s2,s3);
          input   [3:0] x0,x1,x2,x3;
          input   clk,rst;
          output  reg [3:0] s0,s1,s2,s3;
          output  reg done;
          
          parameter   st0 = 3'b000,
                       st1 = 3'b001,
                       st2 = 3'b010,
                       st3 = 3'b011,
                       st4 = 3'b100,
                       st5 = 3'b101,
                       st6 = 3'b110;
                       
          reg     [3:0] t0,t1;
          wire    [3:0] o0,o1;
          reg     [3:0] state;
          wire    flag;
          
          CMP cmp (
              .x0(t0),
              .x1(t1),
              .out(flag)
              );
          /*
          module CMP(x0,x1,out);
          
          input   [3:0] x0,x1;
          output  reg out;
           
          always @ (x0 or x1)
          begin
              if(x0 > x1)
                  out = 1;
              else
                  out = 0;
          end
          
      	endmodule
      	*/
          
          EXG exg (
              .x0(t0),
              .x1(t1),
              .out0(o0),
              .out1(o1)
              );
          /*
          module EXG(x0,x1,out0,out1);
          
          input   [3:0] x0,x1;
          output  [3:0] out0,out1;
          
          assign out0 = x1;
          assign out1 = x0;  
          
      	endmodule
      	*/
          
          always @ (posedge clk or posedge rst)
          begin
              if(rst)
              begin
                  s0 <= x0;
                  s1 <= x1;
                  s2 <= x2;
                  s3 <= x3;
                  done <= 0;
                  t0 <= x0;
                  t1 <= x1;
                  state <= st0;
              end
              else
                  case(state)
                      st0:begin
                              if(flag)
                              begin
                                  s0 = o0;
                                  s1 = o1;
                              end
                              t0 = s1;
                              t1 = s2;
                              state = st1;
                          end
                      st1:begin
                              if(flag)
                              begin
                                  s1 = o0;
                                  s2 = o1;
                              end
                              t0 = s2;
                              t1 = s3;
                              state = st2;
                          end
                      st2:begin
                              if(flag)
                              begin
                                  s2 = o0;
                                  s3 = o1;
                              end
                              t0 = s0;
                              t1 = s1;
                              state = st3;
                          end
                      st3:begin
                              if(flag)
                              begin
                                  s0 = o0;
                                  s1 = o1;
                              end
                              t0 = s1;
                              t1 = s2;
                              state = st4;
                          end
                      st4:begin
                              if(flag)
                              begin
                                  s1 = o0;
                                  s2 = o1;
                              end
                              t0 = s0;
                              t1 = s1;
                              state = st5;
                          end
                      st5:begin
                              if(flag)
                              begin
                                  s0 = o0;
                                  s1 = o1;
                              end
                              done = 1;
                              state = st6;
                          end
                      default:;
                      endcase                              
          end
                  
      endmodule
      
      ```     

  - 除法器

    - 除法原理

      移位+减法

      

    - 代码

      ```verilog
      module DIV(x,y,q,r,rst,clk,error,done);
          
          input   [3:0] x,y;
          input   clk,rst;
          output  reg [3:0] q,r;
          output  reg error,done;
          
          wire    [4:0] xout,yout;
          reg     [4:0] xt,yt;
          reg     [3:0] count;
          reg     [3:0] temp;
          wire    flag;
          reg     [2:0] state;
          
          parameter op1 = 3'b101,
                      op2 = 3'b110;
          
          parameter st0 = 2'b00,
                      st1 = 2'b01,
                      st2 = 2'b10;
          
          ALU minus (
              .OP(op1),
              .A(xt),
              .B(yt),
              .F(xout)
              );
              
          ALU shift (
              .OP(op2),
              .A(1),
              .B(yt),
              .F(yout)
              );
              
      
          assign flag = (xt >= yt) ? 1 : 0;
              
          always @ (posedge clk or posedge rst)
          begin
              if(rst)
              begin
                  xt <= {1'b0,x};
                  yt <= {1'b0,y};
                  count <= 0;
                  error <= 0;
                  done <= 0;
                  temp <= y;
                  state <= st0;
                  q <= 0;
                  r <= 0;
              end
              else if(y == 0)
                  error <= 1;
              else
                  case(state)
                      st0:begin
                              if(flag)
                              begin
                                  temp <= yt;
                                  q <= q + (q == 0 ? 1 : q);
                                  yt <= yout;
                                  state <= st0;
                              end
                              else
                              begin
                                  xt <= xt - temp;
                                  yt <= y;
                                  state <= st1;
                              end
                          end
                      st1:begin
                              if(flag)
                              begin
                                  xt <= xout;
                                  q <= q + 1;
                                  state <= st1;
                              end
                              else
                                  state <= st2;
                          end
                      st2:begin
                              r <= xt;
                              done <= 1;
                          end
                  endcase
          end            
      
      endmodule
      ```
   
- ##### 实验总结

  - 本次实验主要学习了移位除法器的原理、功能与设计方法，重温了状态机和数据通路的基本语法和结构，熟悉了排序器的设计方法，并应用ALU和状态机设计并实现了排序器和除法器。细节方面，学习了有：
    - 移位除法器通过二进制移位和减法实现除法的原理；
    - 状态机的基本原理和分类（一段式、二段式、三段式）
  - 主要反思有：
    - always语句中最好使用非阻塞赋值；
    - 用输入信号reset初始化寄存器，而不是用initial，initial仅用于仿真，对下载无用；
    - 本实验中尽量使用三段式状态机，将同步时序和组合逻辑分别放到不同的always模块中实现，这样做的好处不仅仅是便于阅读、理解、维护，更重要的是利于综合器优化代码，利于用户添加合适的时序约束条件，利于布局布线器实现设计。

