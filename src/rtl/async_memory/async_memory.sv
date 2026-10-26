`ifndef ASYNC_MEM_MODULE
`define ASYNC_MEM_MODULE

        module async_memory #(
            parameter WIDTH = 8,
            parameter N = 8,
            parameter MEM_FILE = ""
          ) (
            input wire clk,
            input wire reset,
            input wire [$clog2(N)-1:0] address,
            input wire [WIDTH-1:0] write_data,
            input wire write,
            output [WIDTH-1:0] read_data
          );

          reg [WIDTH-1:0] mem [0:N-1];
          reg [WIDTH-1:0] mem_backup [0:N-1];


          integer i;
          initial
            if (MEM_FILE != "")
            begin
              $readmemb(MEM_FILE, mem);
              $readmemb(MEM_FILE, mem_backup);
            end
            else
              for (i = 0; i < N; i = i + 1)
              begin
                mem[i] <= {WIDTH{1'b0}};
                mem_backup[i] <= {WIDTH{1'b0}};
              end


          assign read_data = mem[address];

          always @(posedge clk or posedge reset)
          begin

            if (reset)
              for (i = 0; i < N; i = i + 1)
                mem[i] <= mem_backup[i];

            else
            begin

              if (write)
                mem[address] <= write_data;


            end
          end

        endmodule

`endif //ASYNC_MEM_MODULE
