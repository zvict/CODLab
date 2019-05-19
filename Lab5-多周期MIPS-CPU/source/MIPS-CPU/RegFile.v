`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 16:08:16
// Design Name: 
// Module Name: RegFile
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


module RegFile(
    input [4:0]ReadReg1,
    input [4:0]ReadReg2,
    input [4:0]WriteReg,
    input [31:0]WriteData,
    input RegWrite,
    output [31:0]ReadData1,
    output [31:0]ReadData2,
    input [31:0]DDU_addr,
    output [31:0]DDU_reg_data,
    input clk
    );

    reg [31:0]register[0:31];

    initial begin
        register[0]=0;
    end

    assign ReadData1=register[ReadReg1];
    assign ReadData2=register[ReadReg2];
    assign DDU_reg_data = register[DDU_addr[4:0]];

    always@(posedge clk)
    begin
        register[0]=0;
        if(RegWrite==1'b1&&WriteReg!=0)
            register[WriteReg]=WriteData;
    end
    
endmodule
