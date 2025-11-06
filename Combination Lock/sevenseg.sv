module sevenseg(
    input  logic [3:0] bin,     // 4-bit binary input
    output logic [7:0] segs     // 7-seg output (HEX display)
);
    always_comb begin
        case (bin)
            4'h0: segs = 8'b1100_0000; // 0
            4'h1: segs = 8'b1111_1001; // 1
            4'h2: segs = 8'b1010_0100; // 2
            4'h3: segs = 8'b1011_0000; // 3
            4'h4: segs = 8'b1001_1001; // 4
            4'h5: segs = 8'b1001_0010; // 5
            4'h6: segs = 8'b1000_0010; // 6
            4'h7: segs = 8'b1111_1000; // 7
            4'h8: segs = 8'b1000_0000; // 8
            4'h9: segs = 8'b1001_0000; // 9
            4'hA: segs = 8'b1000_1000; // A
            4'hB: segs = 8'b1000_0011; // b
            4'hC: segs = 8'b1100_0110; // C
            4'hD: segs = 8'b1010_0001; // d
            4'hE: segs = 8'b1000_0110; // E
            4'hF: segs = 8'b1000_1110; // F
            default: segs = 8'b1111_1111; // all off
        endcase
    end
endmodule
