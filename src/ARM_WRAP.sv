module ARM_WRAP (
    input clk,
    input key1
);

wire deb_out, rst;
assign rst = ~deb_out;

debouncer deb_inst (
.SIGNAL_I(key1),
.CLK_I(clk),
.SIGNAL_0(deb_out)
);

ARM ARM_inst (
    .clk(clk),
    .rst(rst)
);

ila_0 ila_inst (
.clk(clk), // input wire clk

.probe0(rst), // input wire [0:0] probe0
.probe1(ARM_inst.pc_if), // input wire [31:0] probe1
.probe2(ARM_inst. pc_id), // input wire [31:0] probe2
.probe3(ARM_inst.pc_exe), // input wire [31:0] probe3
.probe4(ARM_inst.pc_mem), // input wire [31:0] probe4
.probe5(ARM_inst.pc_wb), // input wire [31:0] probe5
.probe6(ARM_inst.inst_if_out) // input wire [31:0] probe6
);


endmodule
