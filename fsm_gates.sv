module fsm_gates(
    input  logic clk,
    input  logic RESETN, 
    input  logic E,
    input  logic M,
    output logic LOCKED,
    output logic savePW,
    output logic saveAT,       
    output logic [1:0] present_state 
);

 
    logic [1:0] next_state;
    logic a, b;
    logic next_a, next_b;

    assign a = present_state[1];
    assign b = present_state[0];

    always_comb begin
        LOCKED  = a;
        savePW  = (~a) & b;
        saveAT  = a & b;
    end


    always_comb begin
        next_b = E;
        next_a = (~a & b & ~E | b & ~E & ~M | a & ~b | a & b & E );

        next_state = {next_a, next_b};
    end


    always_ff @(posedge clk) begin
        if (~RESETN)
            present_state <= 0; 
        else
            present_state <= next_state;
    end

endmodule
