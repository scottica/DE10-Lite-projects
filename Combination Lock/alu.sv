module alu(
    input  logic [7:0] A,
    input  logic [7:0] B,
    input  logic [1:0] aluOp, // 00 ADD, 01 SUB, 10 MUL, 11 AND
    output logic [7:0] R,
    output logic [5:0] CC
);

    logic [8:0] add_full;
    logic [8:0] sub_full;
    logic [15:0] mul_full;
    logic [7:0] and_res;

    // addition full result (9 bits)
    assign add_full = {1'b0, A} + {1'b0, B}; // 9-bit sum (carry in msb)
    // subtraction: compute A - B as 9-bit signed unsigned difference
    // Using: sub_full = {1'b0, A} - {1'b0, B}
    assign sub_full = {1'b0, A} - {1'b0, B};
    assign mul_full = $unsigned(A) * $unsigned(B);
    assign and_res  = A & B;

    // default R
    always_comb begin
        unique case (aluOp)
            2'b00: R = add_full[7:0];   // ADD (lower 8 bits)
            2'b01: R = sub_full[7:0];   // SUB (lower 8 bits)
            2'b10: R = mul_full[7:0];   // MUL (lower 8 bits of product)
            2'b11: R = and_res;         // AND
            default: R = 8'd0;
        endcase
    end

    // Condition codes
    // N = sign bit of R
    // Z = (R == 0)
    // C (carry) = carry-out from addition (add_full[8])
    // B (borrow) = borrow-out for subtraction (sub_full[8] == 1 means no borrow? We treat borrow = (A < B))
    // V+ (overflow add) = (A[7] == B[7]) && (R[7] != A[7])
    // V- (overflow sub) = ((A[7] != B[7]) && (R[7] != A[7]))  (standard subtraction overflow)
    //
    // Implemented as:
    logic N_flag, Z_flag;
    logic C_flag; // carry for add
    logic B_flag; // borrow for sub (1 if borrow occurred, i.e., A < B)
    logic Vplus, Vminus;

    always_comb begin
        N_flag = R[7];
        Z_flag = (R == 8'd0);

        // carry-out from addition
        C_flag = add_full[8];

        // borrow: set if A < B (unsigned)
        B_flag = ($unsigned(A) < $unsigned(B));

        // signed overflow add:
        // V+ = ( (~A7 & ~B7 & R7) | (A7 & B7 & ~R7) )
        Vplus  = ((~A[7] & ~B[7] & R[7]) | (A[7] & B[7] & ~R[7]));

        // signed overflow subtract (A - B):
        // V- = ( (A7 & ~B7 & ~R7) | (~A7 & B7 & R7) )
        Vminus = ((A[7] & ~B[7] & ~R[7]) | (~A[7] & B[7] & R[7]));

        // Pack CC: {V+, V-, C, B, Z, N}
        CC = { Vplus, Vminus, C_flag, B_flag, Z_flag, N_flag };
    end

endmodule