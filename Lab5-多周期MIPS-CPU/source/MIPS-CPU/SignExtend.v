`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 16:08:16
// Design Name: 
// Module Name: SignExtend
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


`include "defines.v"

module SignExtend(
    input [15:0]i_num,
    output reg[31:0]o_num,
    input [5:0]op
    );
    reg sel;
    always@(*)begin
        if(op == `EXE_ANDI||op == `EXE_ORI||op == `EXE_XORI)sel=1'b1;
        else sel = 1'b0;
    end
    initial begin
        o_num=0;
    end
    
    always@(*)begin
        if(sel==1'b0)o_num={16*{i_num[15]},i_num[15:0]};
        else o_num={16'b0000000000000000,i_num[15:0]};
    end
endmodule
