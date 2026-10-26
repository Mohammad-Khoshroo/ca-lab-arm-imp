module ALUControl (
    input [6:0] opcode,
    input [2:0] func3,
    input [6:0] func7,
    output reg [2:0] operation
);
    always@(*) begin
        
        case(opcode)
            
            //  R-Types
            7'b0110011:
            
                case(func3)

                    // Add & Sub
                    3'b000:
                        if (func7 == 7'b0100000)
                            operation = 3'b001;
                        else 
                            operation = 3'b000;
                    // And
                    3'b111:
                        operation = 3'b010;
                    // Or
                    3'b110:
                        operation = 3'b011;
                    // SLT
                    3'b010:
                        operation = 3'b110;

                endcase

            //  I-Types
            7'b0010011:
                case(func3) 

                    // Addi
                    3'b000:
                        operation = 3'b000;
                    // Ori
                    3'b110:
                        operation = 3'b011;
                    // SLTi
                    3'b010:
                        operation = 3'b110;

                endcase

            //Jalr
            7'b1100111:
                operation = 3'b000;
            
            // Load Word
            7'b0000011:
                operation = 3'b000;

            // S-Type --- Store Word
            7'b0100011:
                operation = 3'b000;

            // U-Type --- Shift immediate
            7'b0110111:
                operation = 3'b101;

            // B-Type --- Branch equal & Branch Not-equal
            7'b1100011:
                operation = 3'b001;
                        
            // J-Type --- Jal
            7'b1101111:
                operation = 3'b111;

            default:
                operation = 3'b111;
                
        endcase

    end

endmodule