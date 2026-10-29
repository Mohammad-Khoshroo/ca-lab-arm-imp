module ARM (
    input clk,
    input rst
);

    wire        freeze;
    wire        Branch_taken;
    wire [31:0] BranchAddr;
    wire        flush;

    wire [31:0] inst_if_out;
    wire [31:0] inst_id_in;

    wire [31:0] pc_if;
    wire [31:0] pc_id;
    wire [31:0] pc_exe;
    wire [31:0] pc_mem;
    wire [31:0] pc_wb;

    assign freeze       = 1'b0;
    assign Branch_taken = 1'b0;
    assign BranchAddr   = 32'b0;
    assign flush        = 1'b0;

    IF fetch (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .Branch_taken(Branch_taken),
        .BranchAddr(BranchAddr),
        .PC(pc_if),
        .Instruction(inst_if_out)
    );

    IF_Reg fetch_reg (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .flush(flush),
        .PC_in(pc_if),
        .Instruction_in(inst_if_out),
        .PC(pc_id),
        .Instruction(inst_id_in)
    );

    ID_Reg decode_reg (
        .clk(clk),
        .rst(rst),
        .PC_in(pc_id),
        .PC(pc_exe)
    );

    EXE_Reg exe_reg (
        .clk(clk),
        .rst(rst),
        .PC_in(pc_exe),
        .PC(pc_mem)
    );

    MEM_Reg memory_access_reg (
        .clk(clk),
        .rst(rst),
        .PC_in(pc_mem),
        .PC(pc_wb)
    );

endmodule
