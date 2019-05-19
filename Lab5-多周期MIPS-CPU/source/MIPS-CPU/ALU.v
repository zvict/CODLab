`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 16:08:16
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0]A,
    input [31:0]B,
    input [3:0]ALUSel,
    output zero,
    output reg[31:0]result
    );

    initial begin
        result = 0;
    end

    assign zero = (result == 0) ? 1 : 0;

    always@(*)
    begin
        if(ALUSel == 4'b0010)     result = A + B;
        else if(ALUSel == 4'b0000)result = A & B;
        else if(ALUSel == 4'b0001)result = A | B;
        else if(ALUSel == 4'b0110)result = A - B;
        else if(ALUSel == 4'b0111)result = (A < B) ? 1 : 0;
        else if(ALUSel == 4'b1100)result = A ^ B;
        else if(ALUSel == 4'b0011)result = ~(A | B);
        else result = A + B;
    end
    
endmodule
