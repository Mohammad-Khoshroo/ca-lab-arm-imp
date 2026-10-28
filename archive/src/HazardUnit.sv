
module hazard_unit(
    input  logic [4:0] regSrc1D, regSrc2D,
    input  logic [4:0] regSrc1E, regSrc2E, regDestE,
    input  logic [4:0] regDestM,
    input  logic       regWriteEnM,
    input  logic [4:0] regDestW,
    input  logic       regWriteEnW,
    input  logic       branchD,

    output logic [1:0] Forward1E, Forward2E,
    output logic       StallF, StallD,
    output logic       FlushE, FlushD
);

    // ----------------------
    // Forwarding logic
    // ----------------------

    // Forward1E (for regSrc1E)
    
    always@(*) begin
        if (regWriteEnM && (regDestM != 0) && (regDestM == regSrc1E))
            Forward1E = 2'b10; // Forward from MEM
        else if (regWriteEnW && (regDestW != 0) && (regDestW == regSrc1E))
            Forward1E = 2'b01; // Forward from WB
        else
            Forward1E = 2'b00; // No forwarding
    end

    // Forward2E (for regSrc2E)
    
    always@(*) begin
        if (regWriteEnM && (regDestM != 0) && (regDestM == regSrc2E))
            Forward2E = 2'b10;
        else if (regWriteEnW && (regDestW != 0) && (regDestW == regSrc2E))
            Forward2E = 2'b01;
        else
            Forward2E = 2'b00;
    end

    // ----------------------
    // Load-use hazard detection
    // ----------------------

    logic load_use_hazard;

    
    always@(*) begin
        load_use_hazard = 0;
        if (EX_mem_read &&
            ((regDestE != 0) && ((regDestE == regSrc1D) || (regDestE == regSrc2D))))
            load_use_hazard = 1;
    end

    // ----------------------
    // Stall and Flush logic
    // ----------------------

    assign StallF = load_use_hazard;
    assign StallD = load_use_hazard;
    assign FlushE = load_use_hazard || branchD;
    assign FlushD = branchD;

endmodule