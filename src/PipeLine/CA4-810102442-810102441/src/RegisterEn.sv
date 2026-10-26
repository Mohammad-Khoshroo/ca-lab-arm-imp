module RegisterEn #(parameter N = 32) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire clr,
    input wire [N-1:0] d,
    output reg [N-1:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst || clr)
            q <= {N{1'b0}};
        else if (en)
            q <= d; 
    end
endmodule
