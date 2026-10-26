module IF_Stage_Reg (
input clk, rst, freeze, flush,
input [31:0] PC_in, Instruction_in,
output reg [31:0] PC, Instruction

);

endmodule

module IF_Stage (
input clk, rst, freeze, Branch_taken ,
input [31:0] BranchAddr,
output [31:0] PC, Instruction

);

endmodule