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
