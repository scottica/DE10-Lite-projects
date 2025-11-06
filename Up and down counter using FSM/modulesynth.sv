module synth (
	input logic [1:0] KEY,
	input logic [9:0] SW,
	output logic [6:0] HEX0,
	output logic [6:0] HEX1,
	output logic [6:0] HEX2,
	output logic [6:0] HEX3,
	output logic [6:0] HEX4,
	output logic [6:0] HEX5,
	output logic [9:0] LEDR
);

logic [13:0] COUNT;
logic [4:0] THOUSANDS, HUNDREDS, TENS, ONES;
logic [1:0] IDLE = 2'b11;
logic [1:0] COUNTUP = 2'b01;
logic [1:0] COUNTDOWN = 2'b10;
logic [1:0] CURRENT_STATE;

sevenseg one(
	.data(ONES),
	.segment(HEX0)
);

sevenseg tens(
	.data(TENS),
	.segment(HEX1)
);
sevenseg hundreds(
	.data(HUNDREDS),
	.segment(HEX2)
);
sevenseg thousands(
	.data(THOUSANDS),
	.segment(HEX3)
);

assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;

always_comb begin
	THOUSANDS = (COUNT/1000) % 10;
	HUNDREDS = (COUNT/100) % 10;
	TENS = (COUNT/10) % 10;
	ONES = COUNT % 10;
	if(CURRENT_STATE == COUNTDOWN) begin
		LEDR[0] = 0;
		LEDR[1] = 1;
	end
	else if(CURRENT_STATE == COUNTUP) begin
		LEDR[0] = 1;
		LEDR[1] = 0;
	end
	else begin 
		LEDR[0] = 1;
		LEDR[1] = 1;
	end
end

always_ff @(negedge KEY[1]) begin
	case(CURRENT_STATE) 
		IDLE: CURRENT_STATE <= COUNTUP;
		COUNTUP: CURRENT_STATE <= COUNTDOWN;
		COUNTDOWN: CURRENT_STATE <= COUNTUP;
		default: CURRENT_STATE <= IDLE;
	endcase 
end

always_ff @(negedge KEY[0]) begin
	if(!KEY[1]) begin
		COUNT <= SW;
	end
	else begin 
		case(CURRENT_STATE) 
			COUNTUP: begin
				if(COUNT == 9999) 
					COUNT <= 0;
				else 
					COUNT <= COUNT + 1;
			end
			COUNTDOWN: begin
				if(COUNT == 0)
					COUNT <= 9999;
				else
					COUNT <= COUNT - 1;
			end
		endcase
	end	
end

endmodule 

module sevenseg( 
	input logic [4:0] data,
	output logic [6:0] segment
);
always_comb begin 
	case(data) 
		0: segment = 7'b1000000;
		1: segment = 7'b1111001;
		2: segment = 7'b0100100;
		3: segment = 7'b0110000;
		4: segment = 7'b0011001;
		5: segment = 7'b0010010;
		6: segment = 7'b0000010;
		7: segment = 7'b1111000;
		8: segment = 7'b0000000;
		9: segment = 7'b0010000;
		default: segment = 7'b1111111;
	endcase 
end
endmodule