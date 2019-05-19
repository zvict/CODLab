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


module CPU(
    input clk,
    input rst,
    input [31:0]DDU_addr,
    output [5:0]op,
    output [4:0]rs,
    output [4:0]rt,
    output [4:0]rd,
    output [4:0]shamt,
    output [5:0]func,
    output [15:0]immediate,
    output [31:0]ReadData1,
    output [31:0]ReadData2,
    output [31:0]RegWriteData,
    output [31:0]MemDataOut,
    output [31:0]currentAddress,
    output [31:0]result,
    output [3:0]state,
    output [31:0]newAddress,
    output [31:0]DDU_mem_data,
    output [31:0]DDU_reg_data,
    input run,
    output MemWrite,
    output [31:0]BDRData 
    );

    wire RegDst;
    wire CondSrc;
    wire RegWrite;
    wire ALUSrcA;
    wire MemRead;
    wire MemtoReg;
    wire IorD;
    wire IRWrite;
    wire PCWrite;
    wire PCWriteCond;
    wire [1:0]ALUOp;
    wire [1:0]ALUSrcB;
    wire [1:0]PCSrc;
    wire zero;
    wire [31:0]ALUOutData;
    wire [31:0]MemAddress;
    wire PCWre;
    wire [31:0]MemWriteData;
    wire [31:0]MDRData;
    wire [4:0]WriteReg;
    wire [31:0]SignExtendData;
    wire [31:0]SignExtendDatal2;
    wire [31:0]ADRData;
    wire [31:0]ALUA;
    wire [31:0]ALUB;
    wire [3:0]ALUSel;
    wire [25:0]instAddress;
    wire [31:0]JumpAddress;
    wire zerosel;
    wire andout;
    wire orout;

    MUX mux7(
        .in0(zero),
        .in1(~zero),
        .sel({0,CondSrc}),
        .out(zerosel)
        );

    and ad1(andout,zerosel,PCWriteCond);
    or o1(orout,andout,PCWrite);
    and ad2(PCWre,run,orout);

    PC pc(
        .clk(clk),
        .rst(rst),
        .PCWre(PCWre),
        .newAddress(newAddress),
        .currentAddress(currentAddress),
        .beginAddress(0)
        );

    MUX mux1(
        .in0(currentAddress),
        .in1(ALUOutData),
        .sel({0,IorD}),
        .out(MemAddress)
        );

    ControlUnit ctl(
        .clk(clk),
        .state(state),
        .CondSrc(CondSrc),
        .rst(rst),
        .opCode(op),
        .PCWrite(PCWrite),
        .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .IorD(IorD),
        .IRWrite(IRWrite),
        .PCWriteCond(PCWriteCond),
        .PCSrc(PCSrc),
        .ALUOp(ALUOp)
        );
    
    IR ir(
        .MemData(MemDataOut),
        .IRWrite(IRWrite),
        .clk(clk),
        .instOP(op),
        .instRS(rs),
        .instRT(rt),
        .instRD(rd),
        .instSHAMT(shamt),
        .instFUNC(func)
        );

    dist_mem_gen_0 mem(
        .a(MemAddress[9:2]),
        .we(MemWrite),
        .d(BDRData),
        .spo(MemDataOut),
        .dpra(DDU_addr[7:0]),
        .dpo(DDU_mem_data),
        .clk(clk)
        );

    MDR mdr(
        .clk(clk),
        .i_data(MemDataOut),
        .o_data(MDRData)
        );

    MUX mux2(
        .in0(ALUOutData),
        .in1(MDRData),
        .sel({0,MemtoReg}),
        .out(RegWriteData)
        );

    MUX mux3(
        .in0(rt),
        .in1(rd),
        .sel({0,RegDst}),
        .out(WriteReg)
        );

    RegFile RF(
        .clk(clk),
        .ReadReg1(rs),
        .ReadReg2(rt),
        .WriteReg(WriteReg),
        .WriteData(RegWriteData),
        .RegWrite(RegWrite),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .DDU_addr(DDU_addr),
        .DDU_reg_data(DDU_reg_data)
        );

    assign immediate = {rd,shamt,func};
    assign SignExtendDatal2 = SignExtendData << 2;

    SignExtend SE(
        .i_num(immediate),
        .o_num(SignExtendData),
        .op(op)
        );

    ADR AR(
        .clk(clk),
        .i_data(ReadData1),
        .o_data(ADRData)
        );

    BDR BR(
        .clk(clk),
        .i_data(ReadData2),
        .o_data(BDRData)
        );

    MUX mux4(
        .in0(currentAddress),
        .in1(ADRData),
        .sel({0,ALUSrcA}),
        .out(ALUA)
        );

    MUX mux5(
        .in0(BDRData),
        .in1(32'd4),
        .in2(SignExtendData),
        .in3(SignExtendDatal2),
        .sel(ALUSrcB),
        .out(ALUB)
        );

    ALU alu(
        .A(ALUA),
        .B(ALUB),
        .ALUSel(ALUSel),
        .zero(zero),
        .result(result)
        );

    ALUControl acl(
        .ALUOp(ALUOp),
        .ALUSel(ALUSel),
        .funcCode(func),
        .opCode(op)
        );

    ALUOut aou(
        .clk(clk),
        .i_data(result),
        .o_data(ALUOutData)
        );

    assign instAddress = {rs,rt,rd,shamt,func};
    assign JumpAddress = {currentAddress[31:28],instAddress,2'b00};

    MUX mux6(
        .in0(result),
        .in1(ALUOutData),
        .in2(JumpAddress),
        .sel(PCSrc),
        .out(newAddress)
        );

endmodule
