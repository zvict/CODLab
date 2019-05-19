`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 16:08:16
// Design Name: 
// Module Name: IR
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


module IR(
    input [31:0]MemData,
    input IRWrite,
    input clk,
    output reg[5:0]instOP,
    output reg[4:0]instRS,
    output reg[4:0]instRT,
    output reg[4:0]instRD,
    output reg[4:0]instSHAMT,
    output reg[5:0]instFUNC
    );

    always@(posedge clk)
    begin
        if(IRWrite)begin
            instOP <= MemData[31:26];
            instRS <= MemData[25:21];
            instRT <= MemData[20:16];
            instRD <= MemData[15:11];
            instSHAMT <= MemData[10:6];
            instFUNC <= MemData[5:0];
        end
        else begin
            instOP <= instOP;
            instRS <= instRS;
            instRT <= instRT;
            instRD <= instRD;
            instSHAMT <= instSHAMT;
            instFUNC <= instFUNC;
        end
    end
endmodule
