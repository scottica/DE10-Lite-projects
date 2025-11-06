module keypad(
input  logic       MAX10_CLK1_50,
input logic [1:0] KEY,
output logic [6:0] HEX0,
output logic [6:0] HEX1,
output logic [6:0] HEX2,
output logic [6:0] HEX3,
output logic [6:0] HEX4,
output logic [6:0] HEX5,
output logic [9:0] LEDR,
inout  wire  [15:0] ARDUINO_IO
);

initial  begin
	HEX0 = 8'b11111111;
	HEX1 = 8'b11111111;
	HEX2 = 8'b11111111;
	HEX3 = 8'b11111111;
	HEX4 = 8'b11111111;
	HEX5 = 8'b11111111;
end


logic [6:0] hexpattern;

logic clk, rst;
assign clk = KEY[1];
assign rst = KEY[0];

logic [3:0] row_scan, row, col;
logic valid, debounceOK;

wire  [3:0] gpio_row, gpio_col;

assign ARDUINO_IO[7:4] = gpio_row;
assign gpio_col = ARDUINO_IO[3:0];


kb_db debounce(
.clk(MAX10_CLK1_50),
.rst(~rst),
.row_wires(gpio_row),
.col_wires(gpio_col),
.row_scan(row_scan),
.row(row),
.col(col),
.valid(valid),
.debounceOK(debounceOK)
);

enum int unsigned { row3=1, row2=2, row1=3, row0=4, key1=5, key2=6, key3=7, key4=8, key5=9,
key6=10, key7=11, key8=12, key9=13, key0=14, keyA=15, keyB=16, keyC=17, keyD=18,
keyAs=19, keyHa=20}
present_state, next_state, outputs;

logic [19:0] counter;

always_ff @(posedge MAX10_CLK1_50 or negedge rst) begin
	if (!rst)
		counter <= 0;
	else
		counter <= counter + 1;
	end

wire tick = (counter == 20'd50000); 

always_ff @(posedge MAX10_CLK1_50) begin
	if (~rst) begin
		present_state <= row3;
	end
	else if (tick) begin
		present_state <= next_state;
	end
end

logic in_key;
logic in_key_d;
logic key_edge;

assign in_key = (present_state >= key1 && present_state <= keyHa);

always_ff @(posedge MAX10_CLK1_50) begin
	if(~rst)
		in_key_d <= 0;
	else
		in_key_d <= in_key;
	end

assign key_edge = in_key & ~in_key_d;

always_comb begin
	case(present_state)
		row3: begin hexpattern = 7'b1111111; LEDR[9:0] = 10'b0111111111; row_scan = 4'b0111; end
		row2: begin hexpattern = 7'b1111111; LEDR[9:0] = 10'b0111111111; row_scan = 4'b1011; end
		row1: begin hexpattern = 7'b1111111; LEDR[9:0] = 10'b0111111111; row_scan = 4'b1101; end
		row0: begin hexpattern = 7'b1111111; LEDR[9:0] = 10'b0111111111; row_scan = 4'b1110; end
		key1: begin hexpattern = 7'b1111001; LEDR[9:0] = 10'b1110001000; row_scan = 4'b0111; end
		key2: begin hexpattern = 7'b0100100; LEDR[9:0] = 10'b1110000100; row_scan = 4'b0111; end
		key3: begin hexpattern = 7'b0110000; LEDR[9:0] = 10'b1110000010; row_scan = 4'b0111; end
		key4: begin hexpattern = 7'b0011001; LEDR[9:0] = 10'b1101001000; row_scan = 4'b1011; end
		key5: begin hexpattern = 7'b0010010; LEDR[9:0] = 10'b1101000100; row_scan = 4'b1011; end
		key6: begin hexpattern = 7'b0000010; LEDR[9:0] = 10'b1101000010; row_scan = 4'b1011; end
		key7: begin hexpattern = 7'b1111000; LEDR[9:0] = 10'b1100101000; row_scan = 4'b1101; end
		key8: begin hexpattern = 7'b0000000; LEDR[9:0] = 10'b1100100100; row_scan = 4'b1101; end
		key9: begin hexpattern = 7'b0010000; LEDR[9:0] = 10'b1100100010; row_scan = 4'b1101; end
		key0: begin hexpattern = 7'b1000000; LEDR[9:0] = 10'b1100010100; row_scan = 4'b1110; end
		keyA: begin hexpattern = 7'b0001000; LEDR[9:0] = 10'b1110000001; row_scan = 4'b0111; end
		keyB: begin hexpattern = 7'b0000011; LEDR[9:0] = 10'b1101000001; row_scan = 4'b1011; end
		keyC: begin hexpattern = 7'b1000110; LEDR[9:0] = 10'b1100100001; row_scan = 4'b1101; end
		keyD: begin hexpattern = 7'b0100001; LEDR[9:0] = 10'b1100010001; row_scan = 4'b1110; end
		keyAs:begin hexpattern = 7'b0000110; LEDR[9:0] = 10'b1100011000; row_scan = 4'b1110; end
		keyHa:begin hexpattern = 7'b0001110; LEDR[9:0] = 10'b1100010010; row_scan = 4'b1110; end
	endcase
end


always_comb begin
	next_state = present_state;
		case(present_state)
	row3: begin
		if (valid && row == 4'b0111) begin
		if  (col == 4'b0111) next_state = key1;
		else if (col == 4'b1011) next_state = key2;
		else if (col == 4'b1101) next_state = key3;
		else next_state = keyA;
		end
	else if (~valid) next_state = row2;
	else next_state = present_state;
end
row2: begin
	if (valid && row == 4'b1011) begin
	if  (col == 4'b0111) next_state = key4;
	else if (col == 4'b1011) next_state = key5;
	else if (col == 4'b1101) next_state = key6;
	else next_state = keyB;
	end
	else if (~valid) next_state = row1;
	else next_state = present_state;
	end
row1: begin
	if (valid && row == 4'b1101) begin
	if  (col == 4'b0111) next_state = key7;
	else if (col == 4'b1011) next_state = key8;
	else if (col == 4'b1101) next_state = key9;
	else next_state = keyC;
end
	else if (~valid) next_state = row0;
	else next_state = present_state;
end

row0: begin
	if (valid && row == 4'b1110) begin
	if  (col == 4'b0111) next_state = keyAs;
	else if (col == 4'b1011) next_state = key0;
	else if (col == 4'b1101) next_state = keyHa;
	else next_state = keyD;
	end
	else if (~valid) next_state = row3;
	else next_state = present_state;
	end
	
	key0:  if (~valid) next_state = row3;
	key1:  if (~valid) next_state = row3;
	key2:  if (~valid) next_state = row3;
	key3:  if (~valid) next_state = row3;
	key4:  if (~valid) next_state = row3;
	key5:  if (~valid) next_state = row3;
	key6:  if (~valid) next_state = row3;
	key7:  if (~valid) next_state = row3;
	key8:  if (~valid) next_state = row3;
	key9:  if (~valid) next_state = row3;
	keyA:  if (~valid) next_state = row3;
	keyB:  if (~valid) next_state = row3;
	keyC:  if (~valid) next_state = row3;
	keyD:  if (~valid) next_state = row3;
	keyAs: if (~valid) next_state = row3;
	keyHa: if (~valid) next_state = row3;
	default: next_state = row3;
	endcase
end

always_ff @(posedge MAX10_CLK1_50) begin
	if (!rst) begin
		HEX0 <= 7'b1111111;
		HEX1 <= 7'b1111111;
		HEX2 <= 7'b1111111;
		HEX3 <= 7'b1111111;
		HEX4 <= 7'b1111111;
		HEX5 <= 7'b1111111;
	end else if (key_edge) begin
		HEX5 <= HEX4;
		HEX4 <= HEX3;
		HEX3 <= HEX2;
		HEX2 <= HEX1;
		HEX1 <= HEX0;
		HEX0 <= hexpattern;
	end
end

    logic [3:0] key_code;
    logic       key_validn;

    always_ff @(posedge MAX10_CLK1_50 or negedge rst) begin
        if (!rst) begin
            key_code  <= 4'h0;
            key_validn <= 1'b1;
        end else begin
            if (valid) begin
                key_validn <= 1'b0; // active low
                unique case (next_state)
                    key0: key_code <= 4'h0;
                    key1: key_code <= 4'h1;
                    key2: key_code <= 4'h2;
                    key3: key_code <= 4'h3;
                    key4: key_code <= 4'h4;
                    key5: key_code <= 4'h5;
                    key6: key_code <= 4'h6;
                    key7: key_code <= 4'h7;
                    key8: key_code <= 4'h8;
                    key9: key_code <= 4'h9;
                    keyA: key_code <= 4'hA;
                    keyB: key_code <= 4'hB;
                    keyC: key_code <= 4'hC;
                    keyD: key_code <= 4'hD;
                    keyAs: key_code <= 4'hE; // #
                    keyHa: key_code <= 4'hF; // *
                    default: key_code <= 4'h0;
                endcase
            end else begin
                key_validn <= 1'b1;
            end
        end
    end
	 
	 assign ARDUINO_IO[8]  = key_code[0];
    assign ARDUINO_IO[9]  = key_code[1];
    assign ARDUINO_IO[10] = key_code[2];
    assign ARDUINO_IO[11] = key_code[3];
    assign ARDUINO_IO[12] = key_validn;

endmodule