module IF_Stage_Reg (
input clk, rst, freeze, flush,
input [31:0] PC_in, Instruction_in,
output reg [31:0] PC, Instruction

);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 32'b0;
        Instruction <= 32'b0; 
    end
    else if (flush) begin
        PC <= 32'b0;
        Instruction <= 32'b0; 
    end
    else if (freeze) begin
        PC <= PC;
        Instruction <= Instruction;   
    end            
    else begin
        PC <= PC_in;
        Instruction <= Instruction_in;    
    end   
end

endmodule

module IF_Stage (
input clk, rst, freeze, Branch_taken ,
input [31:0] BranchAddr,
output [31:0] PC, Instruction

);

Register #(.WIDTH(32)) PC_reg (
    .clk(clk),
    .reset(rst),
    .enable(!freeze),
    .pl_enable(1'b0),         
    .d(next_PC),
    .pl('0),
    .q(PC)
);

// rom #(
//     .ADDR_WIDTH(32),
//     .DATA_WIDTH(32),
//     .INIT_FILE("output_ultimate.coe"),
//     .SYNCHRONOUS(0)
// )   Ins_mem
//         (
//     .addr(PC),
//     .en(1'b1),
//     .data(Instruction)
//     );

wire [31:0] PC_inc;
assign PC_inc = PC + 1;

wire [31:0] next_PC;
assign next_PC = Branch_taken ? BranchAddr : PC_inc;

endmodule

