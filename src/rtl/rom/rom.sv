`ifndef ROM_MODULE
`define ROM_MODULE

        // Parameterizable ROM (Verilog-2001)
        // - ADDR_WIDTH: address bus width
        // - DATA_WIDTH: data bus width
        // - INIT_FILE:  optional hex file for initialization (use "" for none)
        // - SYNCHRONOUS: 1 = synchronous read (registered output), 0 = asynchronous read (combinational)
        // Notes: use $readmemh for hex file. For synthesis with vendor tools, replace init method with vendor ROM inference if needed.

        module rom #(
            parameter integer ADDR_WIDTH = 8,
            parameter integer DATA_WIDTH = 8,
            parameter string  INIT_FILE  = "",    // e.g. "rom_init.hex" (hex, one word per line)
            parameter integer SYNCHRONOUS = 1
          )(
            input  wire                    clk,   // used only if SYNCHRONOUS==1
            input  wire [ADDR_WIDTH-1:0]   addr,
            input  wire                    en,    // chip enable; when low output is high-Z in some flows (here outputs zero)
            output reg  [DATA_WIDTH-1:0]   data
          );

          localparam integer DEPTH = (1 << ADDR_WIDTH);

          // memory array
          reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

          // initialization
          initial
          begin
            integer i;
            if (INIT_FILE != "")
            begin
              $readmemh(INIT_FILE, mem);
            end
            else
            begin
              for (i = 0; i < DEPTH; i = i + 1)
                mem[i] = {DATA_WIDTH{1'b0}};
            end
          end

          // read logic: synchronous or asynchronous
          generate
            if (SYNCHRONOUS)
            begin : gen_sync
              always @(posedge clk)
              begin
                if (en)
                  data <= mem[addr];
                else
                  data <= {DATA_WIDTH{1'b0}};
              end
            end
            else
            begin : gen_async
              always @(*)
              begin
                if (en)
                  data = mem[addr];
                else
                  data = {DATA_WIDTH{1'b0}};
              end
            end
          endgenerate

        endmodule

        // Example instantiation:
        // rom #(.ADDR_WIDTH(10), .DATA_WIDTH(16), .INIT_FILE("rom_init.hex"), .SYNCHRONOUS(1)) myrom (
        //     .clk(clk),
        //     .addr(addr),
        //     .en(en),
        //     .data(data_out)
        // );
`endif //ROM_MODULE
