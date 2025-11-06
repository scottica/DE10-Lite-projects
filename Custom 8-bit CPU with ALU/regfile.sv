module regfile(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        WE,       // write enable (when high on posedge clk -> write to rA)
    input  logic [1:0]  selA,     // read port A index
    input  logic [1:0]  selB,     // read port B index
    input  logic [7:0]  dataW,    // write data (to register selected by selA on write)
    output logic [7:0]  dataA,    // read dataA (combinational)
    output logic [7:0]  dataB     // read dataB (combinational)
);

    logic [7:0] regs [0:3]; // 4 general-purpose registers (R0–R3)

    // asynchronous read
    assign dataA = regs[selA];
    assign dataB = regs[selB];

    // synchronous write + reset
    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1)
                regs[i] <= 8'd0;
        end else if (WE) begin
            regs[selA] <= dataW; // write to the register selected by selA
        end
    end
endmodule
