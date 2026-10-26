`include "Adder.sv"
`include "ALU.sv"
`include "Controller.sv"
`include "DataMemory.sv"
`include "ImmediateGenerator.sv"
`include "InstructionMemory.sv"
`include "MUX.sv"
`include "Register.sv"
`include "RegisterEn.sv"
`include "RegisterFile.sv"
`include "HazardUnit.sv"

module CPU (
    input clk,rst
);

wire[31:0] PC_nextF, instructionF , PCF ,PC_plus4F;

wire[4:0] regDestD, regSrc1D, regSrc2D;
wire[31:0] PCD, PC_plus4D, regData1D, regData2D ,instructionD ,immediateD;
wire StallF, StallD , FlushD, ALUIn2SrcD, jumpD ,jumpRD ,branchEqD, branchNeqD, memWriteEnD, regWriteEnD;
wire [1:0] regWriteSrcD;
wire [2:0] ALUOpD;

wire[4:0] regSrc1E, regSrc2E ,regDestE;
wire[31:0] ALUResultE, PC_targetE, PC_plus4E ,PCE ,regData1E ,regData2E, immediateE, ALUIn1, ALUIn2;
wire ALUIn2SrcE, jumpE, jumpRE, branchEqE, branchNeqE ,memWriteEnE, regWriteEnE ,FlushE ,zero;
reg [1:0] PCSrcE;
wire [1:0] regWriteSrcE;
wire [2:0] ALUOpE;

wire[4:0] regDestM;
wire[31:0] memWriteDataE, PC_plus4M, memWriteDataM, ALUResultM, memDataM;
wire [1:0] Forward1E, Forward2E;
wire memWriteEnM, regWriteEnM;
wire [1:0] regWriteSrcM;

wire[4:0] regDestW;
wire[31:0] regWriteDataW ,PC_plus4W, memDataW, ALUResultW;
wire regWriteEnW;
wire [1:0] regWriteSrcW;

 

// ######################################################################################################### Hazard Unit

HazardUnit HU(
    .regSrc1D(regSrc1D), 
    .regSrc2D(regSrc2D),

    .regDestE(regDestE),
    .regSrc1E(regSrc1E), 
    .regSrc2E(regSrc2E), 
    .PCSrcE(PCSrcE),
    .regWriteSrcE(regWriteSrcE),

    .regDestM(regDestM),
    .regWriteEnM(regWriteEnM),

    .regDestW(regDestW),
    .regWriteEnW(regWriteEnW),

    .StallF(StallF), 
    .StallD(StallD),
    .FlushD(FlushD),
    .FlushE(FlushE), 
    .Forward1E(Forward1E), 
    .Forward2E(Forward2E)
);

// ######################################################################################################### Fetch

MUX #(32, 2) MUX_PC(
    .in( {32'd0, ALUResultE, PC_targetE, PC_plus4F} ),
    .sel(PCSrcE),
    .out(PC_nextF)
);

RegisterEn #(32) Reg_PC(
    .clk(clk),
    .rst(rst),
    .en(!StallF),
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

// ---------------------------------------------

RegisterEn #(32) instruction_FetchReg(
    .clk(clk),
    .rst(rst),
    .en(!StallD),
    .clr(FlushD),
    .d(instructionF),
    .q(instructionD)
);

RegisterEn #(32) PC_FetchReg(
    .clk(clk),
    .rst(rst),
    .en(!StallD),
    .clr(FlushD),
    .d(PCF),
    .q(PCD)
);

RegisterEn #(32) PC_plus4_FetchReg(
    .clk(clk),
    .rst(rst),
    .en(!StallD),
    .clr(FlushD),
    .d(PC_plus4F),
    .q(PC_plus4D)
);


// ######################################################################################################### DeCode

Controller control_unit(

    .opcode(instructionD[6:0]),
    .func3(instructionD[14:12]),
    .func7(instructionD[31:25]),

    .regWriteEn(regWriteEnD),
    .regWriteSrc(regWriteSrcD),
    .memWriteEn(memWriteEnD),
    .jump(jumpD),
    .jumpR(jumpRD),
    .branchEq(branchEqD),
    .branchNeq(branchNeqD),
    .ALUOp(ALUOpD),
    .ALUIn2Src(ALUIn2SrcD)
);

//--------------------------------------

RegisterEn #(1) regWriteEn_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(regWriteEnD),
    .q(regWriteEnE)
);

RegisterEn #(2) regWriteSrc_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(regWriteSrcD),
    .q(regWriteSrcE)
);

RegisterEn #(1) memWriteEn_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(memWriteEnD),
    .q(memWriteEnE)
);

RegisterEn #(1) jump_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(jumpD),
    .q(jumpE)
);

RegisterEn #(1) jumpR_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(jumpRD),
    .q(jumpRE)
);

RegisterEn #(1) branchEq_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(branchEqD),
    .q(branchEqE)
);

RegisterEn #(1) branchNeq_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(branchNeqD),
    .q(branchNeqE)
);

RegisterEn #(3) ALUOp_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(ALUOpD),
    .q(ALUOpE)
);

RegisterEn #(1) ALUIn2Src_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(ALUIn2SrcD),
    .q(ALUIn2SrcE)
);

//---------------------------------------------

RegisterEn #(32) RFData1_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(regData1D),
    .q(regData1E)
);

RegisterEn #(32) RFData2_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(regData2D),
    .q(regData2E)
);

RegisterEn #(32) PC_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(PCD),
    .q(PCE)
);

assign regSrc1D = instructionD[19:15];
assign regSrc2D = instructionD[24:20]; 

RegisterEn #(5) registerSrc1_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(regSrc1D),
    .q(regSrc1E)
);

RegisterEn #(5) registerSrc2_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(regSrc2D),
    .q(regSrc2E)
);

assign  regDestD = instructionD[11:7];

RegisterEn #(5) registerDest_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(regDestD),
    .q(regDestE)
);

ImmediateGenerator extend(
    .instruction(instructionD),
    .immediate(immediateD)
);

RegisterEn #(32) immediate_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(immediateD),
    .q(immediateE)
);

RegisterEn #(32) PC_plus4_DecodeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(FlushE),
    .d(PC_plus4D),
    .q(PC_plus4E)
);

//----------------------------------------------

RegisterFile RF(
    .clk(!clk),
    .rst(rst),
    .write_enable(regWriteEnW),
    .read_reg1(regSrc1D),
    .read_reg2(regSrc2D),
    .write_reg(regDestW),
    .write_data(regWriteDataW),
    .data1(regData1D),
    .data2(regData2D)
);

// ######################################################################################################### Execute

always @(*) begin
    if (jumpE) begin
        PCSrcE = 2'b01; // Jump
    end else if (jumpRE) begin
        PCSrcE = 2'b10; // Jump Register
    end else if (branchEqE && zero) begin
        PCSrcE = 2'b01; // Branch Equal
    end else if (branchNeqE && !zero) begin
        PCSrcE = 2'b01; // Branch Not Equal
    end else begin
        PCSrcE = 2'b00; // Normal flow
    end
end

//---------------------------------------------

RegisterEn #(1) regWriteEn_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteEnE),
    .q(regWriteEnM)
);

RegisterEn #(2) regWriteSrc_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteSrcE),
    .q(regWriteSrcM)
);

RegisterEn #(1) memWriteEn_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(memWriteEnE),
    .q(memWriteEnM)
);

//---------------------------------------------

RegisterEn #(32) ALU_result_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(ALUResultE),
    .q(ALUResultM)
);

RegisterEn #(32) memWriteData_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(memWriteDataE),
    .q(memWriteDataM)
);

RegisterEn #(5) registerDest_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regDestE),
    .q(regDestM)
);

RegisterEn #(32) PC_plus4_ExeReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(PC_plus4E),
    .q(PC_plus4M)
);

//---------------------------------------------

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

MUX #(32,1) alu_in2_mux(
    .in( {immediateE, memWriteDataE} ),
    .sel(ALUIn2SrcE),
    .out(ALUIn2)
);

ALU computation_unit(
    .a(ALUIn1),
    .b(ALUIn2),
    .select(ALUOpE),
    .result(ALUResultE),
    .zero(zero)
);

// ######################################################################################################### Memory

RegisterEn #(1) regWriteEn_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteEnM),
    .q(regWriteEnW)
);

RegisterEn #(2) regWriteSrc_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regWriteSrcM),
    .q(regWriteSrcW)
);

//----------------------------------------------

RegisterEn #(32) ALUResult_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(ALUResultM),
    .q(ALUResultW)
);

RegisterEn #(32) memData_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(memDataM),
    .q(memDataW)
);

RegisterEn #(5) registerDest_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(regDestM),
    .q(regDestW)
);

RegisterEn #(32) PC_plus4_MemReg(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clr(1'b0),
    .d(PC_plus4M),
    .q(PC_plus4W)
);

//-----------------------------------------------

DataMemory DM(
    .clk(clk),
    .rst(rst),
    .addr(ALUResultM),
    .write_data(memWriteDataM),
    .write_enable(memWriteEnM),
    .read_data(memDataM)
);

// ######################################################################################################### Write Back




MUX #(32, 2) reg_write_mux(
    .in( {ALUResultW, PC_plus4W, memDataW, ALUResultW} ),
    .sel(regWriteSrcW),
    .out(regWriteDataW)
);


endmodule