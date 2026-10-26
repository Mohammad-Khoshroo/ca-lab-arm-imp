`ifndef REGISTER_FILE_MODULE
`define REGISTER_FILE_MODULE

        module RegisterFile #(
            parameter WIDTH = 32,
            parameter SIZE  = 64,
            parameter SRC = "src/rtl/register/constant.mem"
          )(
            input  wire clk,
            input  wire reset,
            input  wire write_enable,
            input  wire [$clog2(SIZE)-1:0] read_addr,
            input  wire [$clog2(SIZE)-1:0] write_addr,
            input  wire [WIDTH-1:0]     write_data,
            output wire [WIDTH-1:0]     out
          );


          reg [WIDTH-1:0] regs [0:SIZE-1];
          reg [WIDTH-1:0] regs_backup [0:SIZE-1];

          // memh is for HEX and memb is for BINARY
          initial
          begin
            $readmemh(SRC, regs);
            $readmemh(SRC, regs_backup);
          end

          assign out = regs[read_addr];

          integer i;

          always @(posedge clk or posedge reset)
          begin

            if (reset)
              for (i = 0; i < SIZE; i = i + 1)
                regs[i] <= regs_backup[i];

            else if (write_enable)
              regs[write_addr] <= write_data;

          end

        endmodule

`endif //REGISTER_FILE_MODULE
