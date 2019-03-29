module FIB(
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
