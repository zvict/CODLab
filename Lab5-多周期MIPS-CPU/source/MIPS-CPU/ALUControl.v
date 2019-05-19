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

module ALUControl(
    input [1:0]ALUOp,
    output reg[3:0]ALUSel,
    input [5:0]funcCode,
    input [5:0]opCode
    );

    always@(*)
    begin
        if(ALUOp == 2'b00)
            ALUSel = 4'b0010;
        else if(ALUOp == 2'b01)
            ALUSel = 4'b0110;
        else if(ALUOp == 2'b11)begin
            case(opCode)
                `EXE_ADDI:  ALUSel = 4'b0010;
                `EXE_ANDI:  ALUSel = 4'b0000;
                `EXE_ORI:   ALUSel = 4'b0001;
                `EXE_XORI:  ALUSel = 4'b1100;
                `EXE_SLTI:  ALUSel = 4'b0111;
                default:    ALUSel = 4'b0010;
            endcase
        end
        else begin
            case(funcCode)
                `EXE_FUNC_ADD:  ALUSel = 4'b0010;
                `EXE_FUNC_SUB:  ALUSel = 4'b0110;
                `EXE_FUNC_AND:  ALUSel = 4'b0000;
                `EXE_FUNC_OR:   ALUSel = 4'b0001;
                `EXE_FUNC_SLT:  ALUSel = 4'b0111;
                `EXE_FUNC_XOR:  ALUSel = 4'b1100;
                `EXE_FUNC_NOR:  ALUSel = 4'b0011;
                default:        ALUSel = 4'b0010;
            endcase
        end
    end
    
endmodule