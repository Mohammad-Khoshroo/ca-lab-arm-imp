module ARM_WRAP (
    input clk,
    input key1
);

    wire deb_out, rst;
    assign rst = ~deb_out;

    debouncer deb_inst (
        .SIGNAL_I(key1),
        .CLK_I(clk),
        .SIGNAL_O(deb_out)
    );

    ARM ARM_inst (
        .clk(clk),
        .rst(rst)
    );

    ILA ila_inst (
        .clk(clk),

        .probe0(rst),                    // [0:0]
        .probe1(ARM_inst.pc_if),         // [31:0]
        .probe2(ARM_inst.pc_id),         // [31:0]
        .probe3(ARM_inst.pc_exe),        // [31:0]
        .probe4(ARM_inst.pc_mem),        // [31:0]
        .probe5(ARM_inst.pc_wb),         // [31:0]
        .probe6(ARM_inst.inst_id_in)     // [31:0] ID instruction (from IF/ID reg)
    );

endmodule
