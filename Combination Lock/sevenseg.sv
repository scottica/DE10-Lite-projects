module sevenseg(
    input  logic [3:0] data,
    output logic [7:0] segments
);

    always_comb
        case (data)
            4'h0:    segments = 8'b11000000;
            4'h1:    segments = 8'b11111001;
            4'h2:    segments = 8'b10100100;
            4'h3:    segments = 8'b10110000;
            4'h4:    segments = 8'b10011001;
            4'h5:    segments = 8'b10010010;
            4'h6:    segments = 8'b10000010;
            4'h7:    segments = 8'b11111000;
            4'h8:    segments = 8'b10000000;
            4'h9:    segments = 8'b10011000;
            4'hA:    segments = 8'b10001000;
            4'hB:    segments = 8'b10000011;
            4'hC:    segments = 8'b10100111;
            4'hD:    segments = 8'b10100001;
            4'hE:    segments = 8'b11110111;
            4'hF:    segments = 8'b11110111;
            default: segments = 8'b11111111;
        endcase
        
endmodule