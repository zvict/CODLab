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


`define RstEnable      1'b1   //复位信号有效
`define RstDisable     1'b0
`define PCWriteEnable  1'b1  //PC地址可以更改
`define PCWriteDisable 1'b0
`define RegWriteEnable 1'b1  //寄存器组写使能
`define RegWriteDisable 1'b0
`define ExtSelZeroExtend 1'b0 //0拓展
`define ExtSelSignExtend 1'b1 //sign_extend



`define EXE_ORI        6'b001101  //指令ori
`define EXE_ADDI       6'b001000
`define EXE_ANDI       6'b001100
`define EXE_XORI       6'b001110
`define EXE_SLTI       6'b001010
`define EXE_SW         6'b101011
`define EXE_LW         6'b100011
`define EXE_BEQ        6'b000100
`define EXE_BNE        6'b000101
`define EXE_J          6'b000010
`define EXE_FUNC_ADD   6'b100000
`define EXE_FUNC_SUB   6'b100010
`define EXE_FUNC_AND   6'b100100
`define EXE_FUNC_OR    6'b100101
`define EXE_FUNC_XOR   6'b100110
`define EXE_FUNC_NOR   6'b100111
`define EXE_FUNC_SLT   6'b101010