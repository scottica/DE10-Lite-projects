module fsm_synth(
    input  logic clk,
    input  logic RESETN,
    input  logic E,
    input  logic M,
    output logic LOCKED,
    output logic savePW,
    output logic saveAT,
    output logic [1:0] stateout
);


    enum int unsigned {
        state_open = 0,
        state_open_press = 1,
        state_locked = 2, 
        state_locked_press = 3
    } present_state, next_state;

    always_comb begin
        LOCKED = 0;
        savePW = 0;
        saveAT = 0;

        case (present_state)
            state_open: begin
                LOCKED = 0;
            end

            state_open_press: begin
                LOCKED = 0;
                savePW = 1;
            end

            state_locked: begin
                LOCKED = 1;
            end

            state_locked_press: begin
                LOCKED = 1;
                saveAT = 1;
            end
        endcase
    end


    always_comb begin
        next_state = present_state;
        case (present_state)
            state_open: begin
                if (E)
						next_state = state_open_press;
            end

            state_open_press: begin
                if (!E)
						next_state = state_locked;
            end

            state_locked: begin
                if (E)	
						next_state = state_locked_press;
            end
				
				state_locked_press: begin
					 if (!E) begin
							if (M)
								next_state = state_open;
							else
								next_state = state_locked;
					 end
				end
							
        endcase
    end

    always_ff @(posedge clk) begin
        if (~RESETN)
            present_state <= state_open;
        else
            present_state <= next_state;
    end

assign state_out = present_state;

endmodule


