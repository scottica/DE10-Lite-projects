module cpu_top (
	input logic       	MAX10_CLK1_50, // DE10-Lite only
	input logic       	CLOCK_50,      // DE1-SoC only
	input logic  [9:0]	SW,
	input logic  [3:0]	KEY,
	output logic [9:0]	LEDR,
	output logic [7:0]	HEX5,
	output logic [7:0]	HEX4,
	output logic [7:0]	HEX3,
	output logic [7:0]	HEX2,
	output logic [7:0]	HEX1,
	output logic [7:0]	HEX0
);



// For remapping board-specific pin names to portable pin names
	logic CLK50; // portable signal name

// Choose which board to target
	localparam enum { DE10LITE, DE1SOC }
		BOARD = DE10LITE;

	generate
		if( BOARD == DE10LITE ) begin
			assign CLK50 = MAX10_CLK1_50;

		end else if( BOARD == DE1SOC ) begin
			assign CLK50 = CLOCK_50;

		end
	endgenerate

// Choose which design to implement
	localparam enum { ALU, REGFILE, CPU }
		DESIGN = CPU;

	
// Design follows below:


	// user interface (inputs)
	logic clk, rst_n, wrA, imm;
	logic [1:0] selA, selB, aluOp, selR;
	assign rst_n = KEY[0];
	assign clk   = KEY[1];
	assign wrA   = SW[9];
	assign selA  = SW[8:7];
	assign selB  = SW[6:5];
	assign imm   = SW[2];
	assign selR  = SW[1:0];

	// user interface (outputs)
	logic [5:0] CC;
	logic [7:0] dataA, outReg, result;		
	sevenseg( dataA[7:4],  HEX5 );
	sevenseg( dataA[3:0],  HEX4 );
	sevenseg( outReg[7:4], HEX3 );
	sevenseg( outReg[3:0], HEX2 );
	sevenseg( result[7:4], HEX1 );
	sevenseg( result[3:0], HEX0 );
	assign LEDR[5:0] = CC;


	generate

		if( DESIGN == ALU ) begin

			// manually input dataA, dataB, aluOp from switches
			logic [7:0] dataB;
			assign aluOp      = SW[9:8];
			assign dataA[3:0] = SW[7:4];
			assign dataB[3:0] = SW[3:0];
			assign dataA[7:4] = { 4{dataA[3]} }; // sign-extended to 8b
			assign dataB[7:4] = { 4{dataB[3]} }; // sign-extended to 8b
			alu(
				.aluOp(aluOp), .A(dataA), .B(dataB), // inputs
				.R(result), .CC(CC)                  // outputs
			);
			assign outReg = dataB; // for visualization

		end else if( DESIGN == REGFILE ) begin

			logic [7:0] dataW;
			assign dataW[3:0] = SW[3:0]; // manually input dataW
			assign dataW[7:4] = { 4{dataW[3]} }; // sign-extended to 8b
			regfile(
				.clk(clk), .rst_n(rst_n),
				.WE(wrA), .selA(selA), .selB(selB), .dataW(dataW), // inputs
				.dataA(dataA), .dataB(outReg)                      // outputs
			);
			assign result = dataW;

		end else if( DESIGN == CPU ) begin

			assign aluOp = SW[4:3];
			cpu(
				.clk(clk), .rst_n(rst_n),
				.wrA(wrA), .selA(selA), .selB(selB),             // inputs
				.aluOp(aluOp), .imm(imm), .selR(selR),           // inputs
				.dataA(dataA), .outReg(outReg), .result(result), // outputs
				.CC(CC)
			);
		
		end

	endgenerate

endmodule