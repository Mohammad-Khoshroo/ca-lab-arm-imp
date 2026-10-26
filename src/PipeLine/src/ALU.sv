module ALU(
    input [31:0] a, b,
    input [2:0] select,
    output reg [31:0] result,
    output zero

);
    always @(*) begin
        
        case (select)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a;
            3'b101: result = b;
            default: result = 0;
        endcase
    
    end
    
    assign zero = (result == 0);

endmodule
