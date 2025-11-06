module safe_digits(
    input  logic       clk, reset, valid,
    input  logic [2:0] main_state,
    output logic [3:0] digit_state
);

    enum int unsigned {
        IDLE = 0,
        D1 = 1,     W1 = 2,
        D2 = 3,     W2 = 4,
        D3 = 5,     W3 = 6,
        D4 = 7,     W4 = 8,
        D5 = 9,     W5 = 10,
        D6 = 11,    W6 = 12,
		START = 13, END = 14
    } CURRENT_STATE, NEXT_STATE;

    // state register
    always_ff @(posedge clk) begin
        if (reset)
            CURRENT_STATE <= IDLE;
        else
            CURRENT_STATE <= NEXT_STATE;
    end

    // next state logic
    always_comb begin
        if (main_state == 3'b000 || main_state == 3'b100)
            NEXT_STATE = IDLE;
        else begin
            case (CURRENT_STATE)
            IDLE: begin
                if (main_state == 3'b001 || main_state == 3'b101)
                    NEXT_STATE = START;
                else
                    NEXT_STATE = IDLE;
            end
			START: begin
				if (~valid) NEXT_STATE = D1;
				else	    NEXT_STATE = START;
			end
            D1: begin
                if (valid)  NEXT_STATE = W1;
                else        NEXT_STATE = D1;
            end
            W1: begin
                if (~valid) NEXT_STATE = D2;
                else        NEXT_STATE = W1;
            end
            D2: begin
                if (valid)  NEXT_STATE = W2;
                else        NEXT_STATE = D2;
            end
            W2: begin
                if (~valid) NEXT_STATE = D3;
                else        NEXT_STATE = W2;
            end
            D3: begin
                if (valid)  NEXT_STATE = W3;
                else        NEXT_STATE = D3;
            end
            W3: begin
                if (~valid) NEXT_STATE = D4;
                else        NEXT_STATE = W3;
            end
            D4: begin
                if (valid)  NEXT_STATE = W4;
                else        NEXT_STATE = D4;
            end
            W4: begin
                if (~valid) NEXT_STATE = D5;
                else        NEXT_STATE = W4;
            end
            D5: begin
                if (valid)  NEXT_STATE = W5;
                else        NEXT_STATE = D5;
            end
            W5: begin
                if (~valid) NEXT_STATE = D6;
                else        NEXT_STATE = W5;
            end
            D6: begin
				if (valid)	NEXT_STATE = END;
                else		NEXT_STATE = D6;
            end
			END: begin
				NEXT_STATE = END;
			end
            default: begin
                NEXT_STATE = IDLE;
            end
            endcase
        end
    end

    // output logic
    always_comb begin
        case (CURRENT_STATE)
        IDLE: 	digit_state = 4'h0;
        D1:		digit_state = 4'h1;
        W1:		digit_state = 4'h2;
        D2:		digit_state = 4'h3;
        W2:		digit_state = 4'h4;
        D3:		digit_state = 4'h5;
        W3:		digit_state = 4'h6;
        D4:		digit_state = 4'h7;
        W4:		digit_state = 4'h8;
        D5:		digit_state = 4'h9;
        W5:		digit_state = 4'hA;
        D6:		digit_state = 4'hB;
		START: 	digit_state = 4'hC;
		END:   	digit_state = 4'hD;
        default: digit_state = 4'h0;
        endcase
    end

endmodule