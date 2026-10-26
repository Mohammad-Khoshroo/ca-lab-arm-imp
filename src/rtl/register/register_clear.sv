`ifndef REGISTER_CLEAR_MODULE
`define REGISTER_CLEAR_MODULE

        module RegisterC #(
            parameter WIDTH = 32,
            parameter INIT = {WIDTH{1'b0}}
          )(
            input wire clk,
            input wire reset,
            input wire enable,
            input wire clear,
            input wire [WIDTH-1:0] d,
            output reg [WIDTH-1:0] q
          );

          always @(posedge clk or posedge reset)
          begin

            if (reset | clear)
              q <= INIT;

            else if (enable)
              q <= d;

          end

        endmodule

`endif // REGISTER_CLEAR_MODULE
