
module aludec(
	input 	logic 		opb5,
	input 	logic [2:0] funct3,
	input	 	logic 		funct7b5,
	input 	logic [1:0] ALUOp,
	output 	logic [2:0] ALUControl);
		
		assign ALUControl[2] = ALUOp[1]& ~ALUOp[0] & ~funct3[2] & funct3[1] & ~funct3[0];
		assign ALUControl[1] = ALUOp[1]& ~ALUOp[0] & funct3[2] & funct3[1];
		assign ALUControl[0] = (~ALUOp[1]& ALUOp[0])
				| ( ALUOp[1]& ~ALUOp[0] & ~funct3[2] & ~funct3[1] & ~funct3[0] & funct7b5 & opb5)
				| ( ALUOp[1]& ~ALUOp[0] & funct3[2] & funct3[1] & ~funct3[0]) 
				| ( ALUOp[1]& ~ALUOp[0] & ~funct3[2] & funct3[1] & ~funct3[0] );
		
		
endmodule