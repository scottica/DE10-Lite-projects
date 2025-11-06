module sevenseg_top( input logic [3:0] SW,
							output logic [6:0] HEX0 );
							
    sevenseg u_sevenseg (
        .data(SW[3:0]),      
        .segments(HEX0)
    );
	 
endmodule