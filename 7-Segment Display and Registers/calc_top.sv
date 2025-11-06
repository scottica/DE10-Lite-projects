module calc_top(
    input  logic [9:0] SW,
    input  logic [1:0] KEY,
    output logic [9:0] LEDR,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

    logic [3:0] A, B;
    logic [3:0] sum;
    logic       cout;

    reg4 regA (
        .clk(KEY[1]),
        .reset_n(KEY[0]),
        .en(SW[9]),
        .d(SW[3:0]),
        .q(A)
    );

    reg4 regB (
        .clk(KEY[1]),
        .reset_n(KEY[0]),
        .en(SW[8]),
        .d(SW[3:0]),
        .q(B)
    );

    assign {cout, sum} = A + B;

    sevenseg hex5_display (.data(A),     .segments(HEX5));
    sevenseg hex3_display (.data(B),     .segments(HEX3)); 
    sevenseg carry_display (.data({3'b000, cout}), .segments(HEX1)); 
    sevenseg sum_display   (.data(sum),            .segments(HEX0));

    assign HEX4 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign LEDR = SW;

endmodule


module reg4 (
    input  logic clk,
    input  logic reset_n,   // active-low synchronous reset
    input  logic en,        // enable
    input  logic [3:0] d,   // 4-bit input
    output logic [3:0] q    // 4-bit output
);


    always_ff @(posedge clk) begin
        if (!reset_n)
            q <= 4'b0000;
        else if (en)
            q <= d;
    end


endmodule