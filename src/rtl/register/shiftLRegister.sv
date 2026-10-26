`ifndef SHIFT_LEFT_REGISTER_MODULE
`define SHIFT_LEFT_REGISTER_MODULE

        module shiftLRegister #(
            parameter WIDTH = 32,
            parameter INIT = {WIDTH{1'b0}}
          )(
            input  wire clk,
            input  wire reset,
            input  wire senable,
            input  wire lenable,
            input  wire serIn,
            input  wire [WIDTH-1:0] load,
            output reg  [WIDTH-1:0] out
          );

          always @(posedge clk or posedge reset)
          begin

            if (reset)
              out <= INIT;

            else if (lenable)
              out <= load;

            else if (senable)
              out <= {out[WIDTH-2:0], serIn};

          end

        endmodule

`endif // SHIFT_LEFT_REGISTER_MODULE
