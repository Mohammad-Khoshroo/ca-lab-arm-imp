module ALU(
    input [31:0] a, b,
    input [2:0] select,
    output reg [31:0] result,
    output zero

);

    reg [31:0] sub;
    always @(*) begin
        
        case (select)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a;
            3'b101: result = b;
            3'b110: begin sub = a - b; result = {31'b0, sub[31]}; end
            default: result = 0;
        endcase
    
    end
    
    assign zero = (result == 0);

endmodule
