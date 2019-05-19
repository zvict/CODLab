`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 21:19:58
// Design Name: 
// Module Name: CPU_tb
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


module CPU_tb();
	reg clk;
    reg rst;
    reg [31:0]DDU_addr;
    reg run;
    wire [5:0]op;
    wire [4:0]rs;
    wire [4:0]rt;
    wire [4:0]rd;
    wire [4:0]shamt;
    wire [5:0]func;
    wire [15:0]immediate;
    wire [31:0]ReadData1;
    wire [31:0]ReadData2;
    wire [31:0]RegWriteData;
    wire [31:0]MemDataOut;
    wire [31:0]currentAddress;
    wire [31:0]result;
    wire [3:0]state;
    wire [31:0]newAddress;
    wire [31:0]DDU_mem_data;
    wire [31:0]DDU_reg_data;
    wire MemWrite;
    wire [31:0]BDRData;

    integer k = 0;

    CPU DUT(
    	.clk           (clk),
    	.rst           (rst),
    	.DDU_addr      (DDU_addr),
    	.op            (op),
    	.rs            (rs),
    	.rt            (rt),
    	.rd            (rd),
    	.shamt         (shamt),
    	.func          (func),
    	.immediate     (immediate),
    	.ReadData1     (ReadData1),
    	.ReadData2     (ReadData2),
    	.RegWriteData  (RegWriteData),
    	.MemDataOut    (MemDataOut),
    	.currentAddress(currentAddress),
    	.result        (result),
    	.state         (state),
    	.newAddress    (newAddress),
    	.DDU_mem_data  (DDU_mem_data),
    	.DDU_reg_data  (DDU_reg_data),
    	.run           (run),
    	.MemWrite      (MemWrite),
    	.BDRData       (BDRData)
    	);

    initial clk = 0;
    always #5 clk = ~clk;

    initial
    begin
    	run = 1;
    	rst = 0;
    	#20 rst = 1;
    	#20 rst = 0;
    	$display("%5d: reset complete.", $time);
    end

endmodule

