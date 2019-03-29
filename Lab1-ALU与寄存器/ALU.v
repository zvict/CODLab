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
