module combo_fsm(
    input  logic       clk, reset, valid, enter, restart, match,
    output logic       setPW, attPW,
    output logic [2:0] state
);

    enum int unsigned {
        PREOPEN = 0,    OPEN = 1,
        PRESET  = 2,    SET  = 3,
        PRELOCK = 4,    LOCK = 5,
        PREATT  = 6,    ATT  = 7
    } CURRENT_STATE, NEXT_STATE;

    // state register
    always_ff @(posedge clk) begin
        if (reset)
            CURRENT_STATE <= OPEN;
        else
            CURRENT_STATE <= NEXT_STATE;
    end

    // next state logic
    always_comb begin
        case (CURRENT_STATE)
        OPEN: begin
            if (valid)  NEXT_STATE = PRESET;
            else        NEXT_STATE = OPEN;
        end
        PRESET: begin
            if (~valid) NEXT_STATE = SET;
            else        NEXT_STATE = PRESET;
        end
        SET: begin
            if      (enter && valid)   NEXT_STATE = PRELOCK;
            else if (restart && valid) NEXT_STATE = PREOPEN;
            else                       NEXT_STATE = SET;
        end
        PRELOCK: begin
            if (~valid) NEXT_STATE = LOCK;
            else        NEXT_STATE = PRELOCK;
        end
        LOCK: begin
            if (valid)  NEXT_STATE = PREATT;
            else        NEXT_STATE = LOCK;
        end
        PREATT: begin
            if (~valid) NEXT_STATE = ATT;
            else        NEXT_STATE = PREATT;
        end
        ATT: begin
            if (enter && valid)
                if (match)  NEXT_STATE = PREOPEN;
                else        NEXT_STATE = PRELOCK;
            else if (restart && valid)  NEXT_STATE = PRELOCK;
            else                        NEXT_STATE = ATT;
        end
        PREOPEN: begin
            if (~valid) NEXT_STATE = OPEN;
            else        NEXT_STATE = PREOPEN;
        end
        default: begin
            NEXT_STATE = OPEN;
        end
        endcase
    end

    // output logic
    always_comb begin
        case (CURRENT_STATE)
        OPEN: begin
            setPW = 1'b0;
            attPW = 1'b0;
            state = 3'b000;
        end
        PRESET: begin
            setPW = 1'b0;
            attPW = 1'b0;
            state = 3'b001;
        end
        SET: begin
            setPW = 1'b1;
            attPW = 1'b0;
            state = 3'b010;
        end
        PRELOCK: begin
            setPW = 1'b0;
            attPW = 1'b0;
            state = 3'b011;
        end
        LOCK: begin
            setPW = 1'b0;
            attPW = 1'b0;
            state = 3'b100;
        end
        PREATT: begin
            setPW = 1'b0;
            attPW = 1'b0;
            state = 3'b101;
        end
        ATT: begin
            setPW = 1'b0;
            attPW = 1'b1;
            state = 3'b110;
        end
        PREOPEN: begin
            setPW = 1'b0;
            attPW = 1'b0;
            state = 3'b111;
        end
        default: begin
            setPW = 1'b0;
            attPW = 1'b0;
            state = 3'b000;
        end
        endcase
    end

endmodule