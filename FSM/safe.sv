module safe(
    input  logic        MAX10_CLK1_50,
    input  logic [1:0]  KEY,
    input  logic [9:0]  SW,
    output logic [9:0]  LEDR,
    output logic [7:0]  HEX5,
    output logic [7:0]  HEX4,
    output logic [7:0]  HEX3,
    output logic [7:0]  HEX2,
    output logic [7:0]  HEX1,
    output logic [7:0]  HEX0
);

    localparam logic [47:0] OPEN_DISPLAY   = 48'hFC_C0_8C_86_AB_F7;
    localparam logic [47:0] LOCKED_DISPLAY = 48'hC7_C0_C6_89_86_C0;

    logic LOCKED, savePW, saveAT;
    logic [9:0] PASSWORD = 0;
	 logic [9:0] ATTEMPT = 1;
    logic MATCH;
    logic [3:0] HINT;
    logic [2:0] PRESENT_STATE;

    fsm_synth FSM (
        .clk           (MAX10_CLK1_50),
        .RESETN        (KEY[0]),
        .E             (~KEY[1]),
        .M             (MATCH),
        .LOCKED        (LOCKED),
        .savePW        (savePW),
        .saveAT        (saveAT),
        .stateout (PRESENT_STATE)
    );

    assign MATCH = (ATTEMPT == PASSWORD);
	 
	 always_comb begin
			HINT = 0;
				for (int i = 0; i < 10; i=i+1) begin
				HINT = HINT + (SW[i] ^ PASSWORD[i]);
				end
	 end

    always_comb begin
        if (LOCKED)
            {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = LOCKED_DISPLAY;
        else
            {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = OPEN_DISPLAY;

        LEDR[3:0] = HINT;
        LEDR[9:8] = PRESENT_STATE;
        LEDR[7:4] = 4'b0000;
    end

    always_ff @(posedge MAX10_CLK1_50) begin
        if (~KEY[0]) begin
            PASSWORD <= 0;
            ATTEMPT  <= 1;
        end
        else begin
            if (savePW)
                PASSWORD <= SW;
            else if (saveAT)
                ATTEMPT <= SW;
        end
    end

endmodule
