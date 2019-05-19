`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/14 16:08:16
// Design Name: 
// Module Name: main
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


module top(
    input cont,
    input step,
    input mem,
    input inc,
    input dec,
    input clk_100MHz,
    input rst,
    output [7:0]pc_led,
    output [7:0]addr_led,
    output [7:0]an,
    output [6:0]seg
    
    );
    wire [7:0]pc;
    wire [31:0]mem_data;
    wire [31:0]reg_data;
    wire [7:0]addr;
    wire run;
    wire [31:0]DDU_addr;

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
    wire [31:0]currentAddress;//pc
    wire  [31:0]result;
    wire [3:0]state;
    wire [31:0]newAddress;
    wire [31:0]DDU_mem_data;
    wire [31:0]DDU_reg_data;
    wire MemWrite;
    wire [31:0]BDRData;
    wire clk;

    CNT cnt(
        .rst(rst),
        .clk_in (clk_100MHz),
        .clk_out(clk)
        );

    assign pc=currentAddress[7:0];

    DDU ddu(
        .cont(cont),
        .step(step),
        .mem(mem),
        .inc(inc),
        .dec(dec),
        .clk(clk_100MHz),
        .rst(rst),
        .pc(pc),
        .mem_data(DDU_mem_data),
        .reg_data(DDU_reg_data),
        .addr(addr),.run(run),
        .pc_led(pc_led),
        .addr_led(addr_led),
        .an(an),
        .seg(seg),
        .clk2(clk)
        );

    assign DDU_addr = {24'h000000,addr};

    CPU cpu(
        .clk(clk&run),
        .rst(rst),
        .DDU_addr(DDU_addr),
        .op(op),
        .rs(rs),
        .rd(rd),
        .rt(rt),
        .shamt(shamt),
        .func(func),
        .immediate(immediate),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .RegWriteData(RegWriteData),
        .MemDataOut(MemDataOut),
        .currentAddress(currentAddress),
        .result(result),
        .state(state),
        .newAddress(newAddress),
        .DDU_mem_data(DDU_mem_data),
        .DDU_reg_data(DDU_reg_data),
        .run(1'b1),
        .MemWrite(MemWrite),
        .BDRData(BDRData)
        );
    
endmodule
