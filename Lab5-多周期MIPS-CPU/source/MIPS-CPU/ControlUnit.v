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

`include"defines.v"

module ControlUnit(
    input clk,
    input rst,
    input [5:0]opCode,
    output reg PCWrite,//PC change to PCSrc
    output reg [1:0]ALUSrcB,//00:regB   01:4  10:signextend[15:0]  11:signextend{[15:0],2'b00}
    output reg ALUSrcA,//PC(if) or reg A(ex)
    output reg RegWrite,//regfile write
    output reg RegDst,//write regfile form rt or rd
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,//write regfile using aluout or mdr
    output reg IorD,//read inst from pc(normal) or aluout 
    output reg IRWrite,
    output reg PCWriteCond,//only if zeor=0
    output reg[1:0]PCSrc,//00:pc+4  01:aluout  10:jump
    output reg[1:0]ALUOp,//00:add  01:sub  10:func 11:opCode
    output reg CondSrc,//bne:1
    output reg [3:0]state
    
    );
    
    reg [3:0]next_state;
    
    parameter FETCH_INST=4'b0000;
    parameter DECODE=4'b0001;
    parameter CALCULATE_ADDR=4'b0010;
    parameter LW_ACCESS_MEM=4'b0011;
    parameter SW_ACCESS_MEM=4'b0101;
    parameter ACCESS_MEM_FIN=4'b0100;
    parameter R_FIN=4'b0111;
    parameter EXECUTION=4'b0110;
    parameter BRANCH_FIN=4'b1000;
    parameter JUMP_FIN=4'b1001;
    parameter N_BRANCH_FIN=4'b1010;
    parameter RI_EXECUTION=4'b1011;
    parameter RI_FIN=4'b1100;
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            state <= FETCH_INST;
        else 
            state <= next_state;
    end
    
    always@(opCode,state)
    begin
        case(state)
            FETCH_INST:next_state=DECODE;
            DECODE:begin
                case(opCode)
                    `EXE_SW:    next_state = CALCULATE_ADDR;
                    `EXE_LW:    next_state = CALCULATE_ADDR;
                    `EXE_BEQ:   next_state = BRANCH_FIN;
                    `EXE_J:     next_state = JUMP_FIN;
                    `EXE_BNE:   next_state = N_BRANCH_FIN;
                    `EXE_ADDI:  next_state = RI_EXECUTION;
                    `EXE_ANDI:  next_state = RI_EXECUTION;
                    `EXE_ORI:   next_state = RI_EXECUTION;
                    `EXE_XORI:  next_state = RI_EXECUTION;
                    `EXE_SLTI:  next_state = RI_EXECUTION;
                    6'b000000:  next_state = EXECUTION;
                    default:    next_state = FETCH_INST;
                endcase
            end
            CALCULATE_ADDR:begin
                case(opCode)
                    `EXE_SW:    next_state = SW_ACCESS_MEM;
                    `EXE_LW:    next_state = LW_ACCESS_MEM;
                    default:    next_state = FETCH_INST;
                endcase
            end
            LW_ACCESS_MEM:  next_state = ACCESS_MEM_FIN;
            SW_ACCESS_MEM:  next_state = FETCH_INST;
            ACCESS_MEM_FIN: next_state = FETCH_INST;
            EXECUTION:      next_state = R_FIN;
            R_FIN:          next_state = FETCH_INST;
            RI_EXECUTION:   next_state = RI_FIN;
            RI_FIN:         next_state = FETCH_INST;
            BRANCH_FIN:     next_state = FETCH_INST;
            N_BRANCH_FIN:   next_state = FETCH_INST;
            JUMP_FIN:       next_state = FETCH_INST;
            default:        next_state = FETCH_INST;
        endcase
    end
    
    always@(state)
    begin
        case (state)
            FETCH_INST:begin
                MemRead     = 1'b1;
                ALUSrcA     = 1'b0;
                IorD        = 1'b0;
                IRWrite     = 1'b1;
                ALUSrcB     = 2'b01;
                ALUOp       = 2'b00;
                PCWrite     = 1'b1;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            DECODE:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b0;
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b11;
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            CALCULATE_ADDR:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b1;//
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b10;//
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            LW_ACCESS_MEM:begin
                MemRead     = 1'b1;//
                ALUSrcA     = 1'b0;
                IorD        = 1'b1;//
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            SW_ACCESS_MEM:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b0;
                IorD        = 1'b1;//
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b1;//
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            ACCESS_MEM_FIN:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b0;
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b1;//
                MemtoReg    = 1'b1;//
                CondSrc     = 1'b0;
            end
            EXECUTION:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b1;//
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b10;//
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            R_FIN:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b0;
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b1;//
                RegWrite    = 1'b1;//
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            RI_EXECUTION:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b1;//
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b10;//
                ALUOp       = 2'b11;//
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            RI_FIN:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b0;
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b1;//
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            BRANCH_FIN:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b1;//
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b01;//
                PCWrite     = 1'b0;
                PCSrc       = 2'b01;//
                MemWrite    = 1'b0;
                PCWriteCond = 1'b1;//
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            N_BRANCH_FIN:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b1;//
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b01;//
                PCWrite     = 1'b0;
                PCSrc       = 2'b01;//
                MemWrite    = 1'b0;
                PCWriteCond = 1'b1;//
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b1;//
            end
            JUMP_FIN:begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b0;
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b00;
                PCWrite     = 1'b1;//
                PCSrc       = 2'b10;//
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
            default : begin
                MemRead     = 1'b0;
                ALUSrcA     = 1'b0;
                IorD        = 1'b0;
                IRWrite     = 1'b0;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b00;
                PCWrite     = 1'b0;
                PCSrc       = 2'b00;
                MemWrite    = 1'b0;
                PCWriteCond = 1'b0;
                RegDst      = 1'b0;
                RegWrite    = 1'b0;
                MemtoReg    = 1'b0;
                CondSrc     = 1'b0;
            end
        endcase
    end
    
endmodule