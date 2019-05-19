`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 18:03:25
// Design Name: 
// Module Name: MUX
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


module MUX(
	input [31:0]in0,
	input [31:0]in1,
	input [31:0]in2,
	input [31:0]in3,
	input [1:0]sel,
	output [31:0]out
    );
	
	/*
		2'b00 -> in0;
		2'b01 -> in1;
		2'b10 -> in2;
		2'b11 -> in3;
	*/
	assign out = (sel[1]==1'b1)?((sel[0]==1'b1)?in3:in2):((sel[0]==1'b1)?in1:in0);

endmodule
