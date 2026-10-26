
module HazardUnit(
    input [4:0] regSrc1D, 
    input [4:0] regSrc2D, 

    input [4:0] regDestE, 
    input [4:0] regSrc1E,  
    input [4:0] regSrc2E,  
    input [1:0] PCSrcE, 
    input [1:0] regWriteSrcE, 

    input [4:0] regDestM, 
    input regWriteEnM, 

    input [4:0] regDestW, 
    input regWriteEnW, 

    output reg StallF, 
    output reg StallD, 
    output reg FlushD, 
    output reg FlushE,
    output reg [1:0] Forward1E, 
    output reg [1:0] Forward2E 
);

    always @(*) begin
        if((regSrc1E == regDestM) && regWriteEnM && (regSrc1E != 0)) begin
            Forward1E = 2'b10; // Forward from M stage
        end else if((regSrc1E == regDestW) && regWriteEnW && (regSrc1E != 0)) begin
            Forward1E = 2'b01; // Forward from W stage
        end else begin
            Forward1E = 2'b00; // No forwarding
        end

        if((regSrc2E == regDestM) && regWriteEnM && (regSrc2E != 0)) begin
            Forward2E = 2'b10; // Forward from M stage
        end else if((regSrc2E == regDestW) && regWriteEnW && (regSrc2E != 0)) begin
            Forward2E = 2'b01; // Forward from W stage
        end else begin
            Forward2E = 2'b00; // No forwarding
        end


    end

    wire lwStall = (regSrc1D == regDestE || regSrc2D == regDestE) && (regWriteSrcE == 2'b01 || regWriteSrcE == 2'b11);
    assign StallD = lwStall;
    assign StallF = lwStall;

    assign FlushD = (PCSrcE != 2'b00);
    assign FlushE = lwStall || (PCSrcE != 2'b00);


endmodule