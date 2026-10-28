module IF_Reg (
    input clk, rst,
    input freeze, flush,
    input [31:0] PC_in, [31:0] Instruction_in,
    output reg [31:0] PC, Instruction
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PC          <= 32'b0;
            Instruction <= 32'b0;
        end
        else if (flush) begin
            PC          <= 32'b0;
            Instruction <= 32'b0;
        end
        else if (!freeze) begin
            PC          <= PC_in;
            Instruction <= Instruction_in;
        end
    end

endmodule


module IF (
    input clk, rst,
    input freeze, Branch_taken,
    input [31:0] BranchAddr,
    output [31:0] PC, Instruction
);

    wire [31:0] next_PC;
    wire [31:0] PC_inc;

    Register #(.WIDTH(32)) PC_reg (
        .clk(clk),
        .reset(rst),
        .enable(!freeze),
        .d(next_PC),
        .q(PC)
    );

    instruction_mem inst_rom (
        .a(PC[10:0]),      // input wire [10 : 0] a
        .spo(Instruction)  // output wire [31 : 0] spo
    );

    assign PC_inc = PC + 32'd1;
    assign next_PC = Branch_taken ? BranchAddr : PC_inc;

endmodule
