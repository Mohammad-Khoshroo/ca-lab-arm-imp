`ifndef CYCLE_BARREL_SHIFT_MODULE
`define CYCLE_BARREL_SHIFT_MODULE

        module cycleBarrelShifter #(
            parameter WIDTH = 32
          )(
            input  wire [WIDTH-1:0] data_in,
            input  wire [$clog2(WIDTH)-1:0] shift_amount,

            // 0 = Left, 1 = Right
            input  wire direction,

            output wire [WIDTH-1:0] data_out
          );

          wire [WIDTH-1:0] shift_left, shift_right;

          assign shift_left  =(data_in << shift_amount) | (data_in >> (WIDTH - shift_amount));
          assign shift_right =(data_in >> shift_amount) | (data_in << (WIDTH - shift_amount));

          assign data_out = direction ? shift_right : shift_left;

        endmodule


`endif //CYCLE_BARREL_SHIFT_MODULE
