module cpu(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        wrA,
    input  logic [1:0]  selA,
    input  logic [1:0]  selB,
    input  logic [1:0]  aluOp,
    input  logic        imm,
    input  logic [1:0]  selR,
    output logic [7:0]  dataA,
    output logic [7:0]  outReg,
    output logic [7:0]  result,
    output logic [5:0]  CC
);

    logic [7:0] A, B, aluB, aluR, nextDataW;
    logic [5:0] aluCC;
    logic [7:0] mem [0:127];
    integer i;

    // Register file
    regfile u_regfile(
        .clk   (clk),
        .rst_n (rst_n),
        .WE    (wrA),
        .selA  (selA),
        .selB  (selB),
        .dataW (nextDataW),
        .dataA (A),
        .dataB (B)
    );

    assign dataA  = A;
    assign result = aluR;
    assign CC     = aluCC;

    // Immediate operand
    always_comb begin
        if (imm)
            aluB = (selR == 2'b00) ? 8'd1 :
                    (selR == 2'b01) ? 8'hFF : 8'd0;
        else
            aluB = B;
    end

    // ALU
    alu u_alu(
        .A(A), .B(aluB), .aluOp(aluOp),
        .R(aluR), .CC(aluCC)
    );

    // choose data to write into regfile (ALU result or memory for LOAD)
    always_comb begin
        nextDataW = aluR;
        if (aluOp == 2'b10 && imm) // LOAD
            nextDataW = mem[B[6:0]];
    end

    // memory and output register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0; i<128; i++) mem[i] <= 8'd0;
            outReg <= 8'd0;
        end else begin
            if (aluOp == 2'b11 && imm && !wrA) begin
                if (B[7])
                    outReg <= A;       // address ≥128 → output device
                else
                    mem[B[6:0]] <= A;  // STORE
            end
        end
    end

    assign outReg = outReg; // holds last written value
endmodule
