`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 16:08:16
// Design Name: 
// Module Name: Multi-cycle_cpu
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

module PC(
    input clk,
    input rst,
    input PCWre,//PCWriteCond*zero+PCWrite
    input [31:0]newAddress,
    input [31:0]beginAddress,//initial address,normal:0
    output reg [31:0]currentAddress
    );

    always@(posedge clk)
    begin
        if(rst)
            currentAddress <= beginAddress;
        else begin
            if(PCWre)
                currentAddress <= newAddress;
            else 
                currentAddress <= currentAddress;
        end
    end
    
endmodule