`include "ALUControl.sv"

module Controller(
    input [6:0] opcode,
    input [2:0] func3,
    input [6:0] func7,
    output [2:0] ALUOp,
    output reg [1:0] regWriteSrc,
    output reg memWriteEn,ALUIn2Src,regWriteEn,jump,jumpR,branchEq, branchNeq
);

    ALUControl alu_controller(
        .opcode(opcode),
        .func3(func3), 
        .func7(func7),
        .operation(ALUOp)
    );

    always @(*) begin

        case (opcode)
            
            // R-Type
            7'b0110011: begin
                if (func3 == 3'b010)
                    regWriteSrc = 2'b11;     
                else
                    regWriteSrc = 2'b00;
                jump = 0;
                jumpR = 0;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 0;
                ALUIn2Src = 0;
                regWriteEn = 1;
            end

            // I-Type arithmetic
            7'b0010011: begin
                if (func3 == 3'b010)
                    regWriteSrc = 2'b11;     
                else 
                    regWriteSrc = 2'b00;
                jump = 0;
                jumpR = 0;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 0;
                ALUIn2Src = 1;
                regWriteEn = 1;
            end

            // I-Type Load Word
            7'b0000011: begin
                regWriteSrc = 2'b01;    
                jump = 0;
                jumpR = 0;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 0;
                ALUIn2Src = 1;
                regWriteEn = 1;
            end

            // I-Type Jalr
            7'b1100111: begin
                regWriteSrc = 2'b10;
                jump = 0;
                jumpR = 1;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 0;
                ALUIn2Src = 1;
                regWriteEn = 1;
            end

            // S-Type
            7'b0100011: begin
                regWriteSrc = 2'b00;
                jump = 0;
                jumpR = 0;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 1;
                ALUIn2Src = 1;
                regWriteEn = 0;
            end

            // B-Type
            7'b1100011: begin
                memWriteEn = 0;
                ALUIn2Src = 0;
                regWriteEn = 0;
                regWriteSrc = 2'b00;
                jump = 0;
                jumpR = 0;
                case (func3)
                    3'b000: begin // BEQ
                        branchEq = 1;
                        branchNeq = 0;
                    end
                    3'b001: begin // BNE
                        branchEq = 0;
                        branchNeq = 1;
                    end
                    default: begin
                        branchEq = 0;
                        branchNeq = 0;
                    end
                endcase

            end

            // U-Type
            7'b0110111: begin
                regWriteSrc = 2'b00;
                jump = 0;
                jumpR = 0;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 0;
                ALUIn2Src = 1;
                regWriteEn = 1;
            end
            
            // J-Type
            7'b1101111: begin
                regWriteSrc = 2'b10;
                jump = 1;
                jumpR = 0;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 0;
                ALUIn2Src = 1;
                regWriteEn = 1;
            end


            default: begin
                regWriteSrc =2'b00;
                jump = 0;
                jumpR = 0;
                branchEq = 0;
                branchNeq = 0;
                memWriteEn = 0;
                ALUIn2Src = 0;
                regWriteEn = 0;
            end
        endcase
    end
endmodule