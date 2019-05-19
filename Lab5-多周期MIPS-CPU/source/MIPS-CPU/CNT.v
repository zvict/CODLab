`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/10 19:22:28
// Design Name: 
// Module Name: CNT
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


module CNT(
    input rst,
    input clk_in,
    output reg clk_out
    );

    reg [19:0] j;
    
    always @(posedge clk_in or posedge rst)
    begin
        if(rst)
        begin
            clk_out <= 0;
            j <= 0;
        end
        else
        begin
            if(j == 49999)
            begin
                j <= 0;
                clk_out <= ~clk_out;
                end
            else
                j <= j + 1;
        end
    end
endmodule
