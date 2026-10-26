`include "Adder.sv"
`include "ALU.sv"
`include "Controller.sv"
`include "DataMemory.sv"
`include "ImmediateGenerator.sv"
`include "InstructionMemory.sv"
`include "MUX.sv"
`include "Register.sv"
`include "RegisterFile.sv"
`include "HazardUnit.sv"

module CPU (
    input clk,rst
);

wire[31:0] PC_nextF, instructionF , PCF ,PC_plus4F;

wire[4:0] regDestD, regSrc1D, regSrc2D;
wire[31:0] PCD, PC_plus4D, regData1D, regData2D ,instructionD ,immediateD;
wire stallD,flushD, ALUIn2SrcD, jumpD ,jumprD ,branchD, memWriteEnD, regWriteEnD;
wire [1:0] regWriteSrcD;
wire [2:0] ALUOpD;

wire[4:0] regSrc1E, regSrc2E ,regDestE;
wire[31:0] ALUResultE, PC_targetE, PC_plus4E ,PCE ,regData1E ,regData2E, immediateE, ALUIn1, ALUIn2;
wire ALUIn2SrcE, jumpE, jumprE, branchE ,memWriteEnE, regWriteEnE ,flushE ,zero;
wire [1:0] PCSrcE ,regWriteSrcE;
wire [2:0] ALUOpE;

wire[4:0] regDestM;
wire[31:0] memWriteDataE, PC_plus4M, memWriteDataM, ALUResultM, memDataM;
wire  regWriteEnM ,memWriteEnM, Forward1E;
wire [1:0] regWriteSrcM;

wire[4:0] regDestW;
wire[31:0] regWriteDataW ,PC_plus4W, memDataW, ALUResultW;
wire regWriteEnW;
wire [1:0] regWriteSrcW;


hazard_unit HU(
    .regSrc1D(regSrc1D), 
    .regSrc2D(regSrc2D),
    .regSrc1E(regSrc1E), 
    .regSrc2E(regSrc2E), 
    .regDestE(regDestE),
    .regDestM(regDestM),
    .regWriteEnM(regWriteEnM),
    .regDestW(regDestW),
    .regWriteEnW(regWriteEnW),
    .branchD(branchD),
    .Forward1E(Forward1E), 
    .Forward2E(Forward2E),
    .oStallF(oStallF), 
    .StallD(StallD),
    .FlushE(FlushE), 
    .FlushD(FlushD)
);

// Fetch

MUX #(32, 2) MUX_PC(
    .in( {32'd0, ALUResultE, PC_targetE, PC_plus4F} ),
    .sel(PCSrcE),
    .out(PC_nextF)
);

RegisterEn #(32) Reg_PC(
    .clk(clk),
    .rst(rst),
    .en(~stallF),
    .d(PC_nextF),
    .q(PCF)
);

InstructionMemory IM(
    .pc(PCF),
    .instruction(instructionF)
);

Adder nextPC(
    .a(PCF),
    .b(32'd4),
    .carry_in(1'b0),
    .sum(PC_plus4F)
);


RegisterEn #(32) instruction_FetchReg(
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clr(flushD),
    .d(instructionF),
    .q(instructionD)
);

RegisterEn #(32) PC_FetchReg(
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clr(flushD),
    .d(PCF),
    .q(PCD)
);

RegisterEn #(32) PC_plus4_FetchReg(
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clr(flushD),
    .d(PC_plus4F),
    .q(PC_plus4D)
);


// DeCode

Controller control_unit(
    .opcode(instructionD[6:0]),
    .func3(instructionD[14:12]),
    .func7(instructionD[31:25]),
    .ALUOp(ALUOpD),
    .ALUIn2Src(ALUIn2SrcD),
    .jump(jumpD),
    .jumpr(jumprD),
    .branch(branchD),
    .regWriteSrc(regWriteSrcD),
    .memWriteEn(memWriteEnD),
    .regWriteEn(regWriteEnD)
);
RegisterEn #(1) ALUIn2Src_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(ALUIn2SrcD),
    .q(ALUIn2SrcE)
);
RegisterEn #(3) ALUOp_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(ALUOpD),
    .q(ALUOpE)
);
RegisterEn #(1) jump_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(jumpD),
    .q(jumpE)
);
RegisterEn #(1) jumpr_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(jumprD),
    .q(jumprE)
);
RegisterEn #(1) branch_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(branchD),
    .q(branchE)
);
RegisterEn #(1) memWriteEn_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(memWriteEnD),
    .q(memWriteEnE)
);
RegisterEn #(1) regWriteEn_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(regWriteEnD),
    .q(regWriteEnE)
);
RegisterEn #(2) regWriteSrc_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(regWriteSrcD),
    .q(regWriteSrcE)
);


RegisterEn #(32) PC_plus4_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(PC_plus4D),
    .q(PC_plus4E)
);RegisterEn #(32) PC_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(PCD),
    .q(PCE)
);


assign regSrc1D = instructionD[19:15];
RegisterEn #(5) registerSrc1_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(regSrc1D),
    .q(regSrc1E)
);
assign regSrc2D = instructionD[24:20]; 
RegisterEn #(5) registerSrc2_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(regSrc2D),
    .q(regSrc2E)
);
assign  regDestD = instructionD[11:7];
RegisterEn #(5) registerDest_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(regDestD),
    .q(regDestE)
);
RegisterFile RF(
    .clk(clk),
    .rst(rst),
    .write_enable(regWriteEnW),
    .read_reg1(regSrc1D),
    .read_reg2(regSrc2D),
    .write_reg(regDestW),
    .write_data(regWriteDataW),
    .data1(regData1D),
    .data2(regData2D)
);
RegisterEn #(32) RFData1_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(regData1D),
    .q(regData1E)
);
RegisterEn #(32) RFData2_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(regData2D),
    .q(regData2E)
);

ImmediateGenerator extend(
    .instruction(instructionD),
    .immediate(immediateD)
);
RegisterEn #(32) immediate_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(flushE),
    .d(immediateD),
    .q(immediateE)
);


// Execute

assign PCSrcE = jumprE ? 2'b10:
((~branchE & zero) | (branchE & ~zero)) | jumpE ? 2'b01 : 2'b00;

RegisterEn #(2) regWriteSrc_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteSrcE),
    .q(regWriteSrcM)
);
RegisterEn #(1) regWriteEn_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteEnE),
    .q(regWriteEnM)
);
RegisterEn #(1) memWriteEn_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(memWriteEnE),
    .q(memWriteEnM)
);

Adder PC_jump(
    .a(PCE),
    .b(immediateE),
    .carry_in(1'b0),
    .sum(PC_targetE)
);

MUX #(32,2) Forward1E_mux(
    .in( {32'd0,ALUResultM ,regWriteDataW, regData1E} ),
    .sel(Forward1E),
    .out(ALUIn1)
);
MUX #(32,2) Forward2E_mux(
    .in( {32'd0,ALUResultM ,regWriteDataW, regData2E} ),
    .sel(Forward2E),
    .out(memWriteDataE)
);
MUX #(32, 1) alu_in2_mux(
    .in( {immediateE, memWriteDataE} ),
    .sel(ALUIn2SrcE),
    .out(ALUIn2)
);
ALU computation_unit(
    .a(ALUIn1),
    .b(ALUIn2),
    .select(ALUOp),
    .result(ALUResultE),
    .zero(zero)
);

RegisterEn #(32) PC_plus4_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(PC_plus4E),
    .q(PC_plus4M)
);
RegisterEn #(5) registerDest_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regDestE),
    .q(regDestM)
);
RegisterEn #(32) memWriteData_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(memWriteDataE),
    .q(memWriteDataM)
);
RegisterEn #(32) ALU_result_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(ALUResultE),
    .q(ALUResultM)
);


// Memory

RegisterEn #(2) regWriteSrc_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteSrcM),
    .q(regWriteSrcW)
);
RegisterEn #(1) regWriteEn_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteEnM),
    .q(regWriteEnW)
);

DataMemory DM(
    .clk(clk),
    .rst(rst),
    .addr(ALUResultM),
    .write_data(memWriteDataM),
    .write_enable(memWriteEnM),
    .read_data(memDataM)
);

RegisterEn #(32) PC_plus4_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(PC_plus4M),
    .q(PC_plus4W)
);
RegisterEn #(5) registerDest_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regDestM),
    .q(regDestW)
);
RegisterEn #(32) memData_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(memDataM),
    .q(memDataW)
);
RegisterEn #(32) ALUResult_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(ALUResultM),
    .q(ALUResultW)
);

// Write Back
wire [31:0] ALUResultSign = {31'b0, ALUResult[31]};
MUX #(32, 2) reg_write_mux(
    .in( {ALUResultSign, PC_plus4W, memDataW, ALUResultW} ),
    .sel(regWriteSrcW),
    .out(regWriteDataW)
);


endmodule