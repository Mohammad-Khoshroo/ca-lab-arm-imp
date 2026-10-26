`timescale 1ns / 1ps

module tb_ARM();


reg clk;
reg rst;

ARM uut (
.clk(clk),
.rst(rst)
);

always #5 clk = ~clk;

initial begin

clk = 0;
rst = 1; 


#20;
rst = 0; 


#100;


$finish;
end


initial begin
$monitor("Time = %0t ns | rst = %b | PC_IF = %0h | PC_ID = %0h | PC_EXE = %0h | PC_MEM = %0h | PC_WB = %0h",
$time, rst, uut.pc_if, uut.pc_id, uut.pc_exe, uut.pc_mem, uut.pc_wb);
end

endmodule
