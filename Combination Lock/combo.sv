module combo(
    input  logic        MAX10_CLK1_50,
    input  logic [1:0]  KEY,
    input  logic [3:0]  SW,
	input  logic [12:8] ARDUINO_IO,
    output logic [9:0]  LEDR,
    output logic [7:0]  HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);
	
    logic key_validn, key_validn_int, key_Validn_sync;
	logic [3:0] key_code, key_code_int, key_code_sync;
	logic [1:0] count;
	
    logic reset, full, enter, restart, match;
    logic setPW, attPW;
	logic [23:0] password, attempt, temp;
	
    logic [2:0] main_state;
    logic [3:0] digit_state;
	
    logic [3:0] digitnum;
    logic [7:0] digitdisplay;
	
    localparam logic [47:0] OPEN = 48'hF7_C0_8C_86_AB_F7;
    localparam logic [47:0] LOCKED = 48'hC7_C0_C6_89_86_C0;
	
	assign reset = ~KEY[0];
    
    
	assign key_validn = ~ARDUINO_IO[12];
	assign key_code[3:0] = ARDUINO_IO[11:8];
    
    
    /*
    assign key_validn = ~KEY[1];
    assign key_code[3:0] = SW[3:0];
    */
    
    assign LEDR[3:0] = SW;
	assign LEDR[5:4] = {2{key_validn_sync}};
	assign LEDR[9] = match;
    assign LEDR[8] = setPW;
    assign LEDR[7] = attPW;

	// fsm controlling main open/locked states
    combo_fsm myfsm(
        MAX10_CLK1_50, reset, key_validn_sync, enter, restart, match,
        setPW, attPW, main_state
    );
	
	// fsm controlling which digit in the pw
    safe_digits mysd(
        MAX10_CLK1_50, reset, key_validn_sync, main_state,
        digit_state
    );

	// converts pw/att digit to hex display
    sevenseg display(
        digitnum,
        digitdisplay
    );
	
	// synchronizer
	always_ff @(posedge MAX10_CLK1_50) begin
        key_validn_int <= key_validn;
		key_validn_sync <= key_validn_int;
		
		key_code_int <= key_code;
		key_code_sync <= key_code_int;
	end
	
	// samples the valid pw/att digit
    always_ff @(posedge MAX10_CLK1_50) begin
        if (reset) begin
            digitnum <= 4'b0000;
			count <= 2'b00;
		end
        else if (key_validn_sync) begin
            count <= count + 1;
			
			if (count == 2'b10)
				digitnum <= key_code_sync;
		end
		else if (~key_validn_sync)
			count <= 2'b00;
    end

	 // set password and attempt
    always_ff @(posedge MAX10_CLK1_50) begin
        if (reset) begin
            password <= 24'h111111; // changed from 0s to 1s
            attempt <= 24'h000000;  // changed from 1s to 0s
        end
        else if (setPW && ~full)
            password <= temp;
        else if (attPW && ~full)
            attempt <= temp;
    end

	// stores pw/att as digits come in
    always_ff @(posedge MAX10_CLK1_50) begin
        if (reset)
            temp <= 24'h111111; // changed temp to 1s from 0s
        else if (main_state == 3'b000 || main_state == 3'b100)
            temp <= 24'h111111;
        else begin
            case (digit_state)
            4'h1: temp[23:20] <= digitnum;
            4'h3: temp[19:16] <= digitnum;
            4'h5: temp[15:12] <= digitnum;
            4'h7: temp[11:8]  <= digitnum;
            4'h9: temp[7:4]   <= digitnum;
            4'hb: temp[3:0]   <= digitnum;
            endcase
        end
    end

	// updates hex display as digits come in
	always_ff @(posedge MAX10_CLK1_50) begin
	    if (reset || main_state == 3'b000)
            {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} <= OPEN;
        else if (main_state == 3'b100)
            {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} <= LOCKED;
        else begin
            case (digit_state)
			4'hC: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0}
                       <= {digitdisplay, 40'hFF_FF_FF_FF_FF};
            4'h1: HEX4 <= 8'hF7;
			4'h2: HEX4 <= digitdisplay;
            4'h3: HEX3 <= 8'hF7;
			4'h4: HEX3 <= digitdisplay; 
            4'h5: HEX2 <= 8'hF7;
			4'h6: HEX2 <= digitdisplay;
            4'h7: HEX1 <= 8'hF7;
			4'h8: HEX1 <= digitdisplay;
            4'h9: HEX0 <= 8'hF7;
			4'hA: HEX0 <= digitdisplay;
            endcase
        end
    end
	
    always_comb begin
        enter = (digitnum == 4'hE);
        restart = (digitnum == 4'hF);
        full = (digit_state == 4'hD);
        match = (password == attempt);
    end

endmodule