module testbench_aludec();
        logic             clk, reset;
        logic [1:0]        ALUOp; 
        logic [2:0]        funct3; 
        logic             opb5;
        logic             funct7b5;
        logic [2:0]        ALUControl, ALUControlExpected;
        logic [31:0]    vectornum, errors;
        logic [9:0]        testvectors[10000:0];


aludec dut(opb5, funct3, funct7b5, ALUOp, ALUControl);

always
        begin
                clk=1; #5;
                clk=0; #5;
        end


initial
        begin
                $readmemb("testbench_aludec.tv", testvectors);
                vectornum=0;
                errors=0;

                reset=1; #22;
                reset=0;
        end

always @(posedge clk)
        begin
                #1;
                {ALUOp, funct3, opb5, funct7b5, ALUControlExpected} = testvectors[vectornum];
        end


always @(negedge clk)

        if (~reset) begin

                if (ALUControl !== ALUControlExpected ) begin

                        $display("Error: inputs = %b, %b, %b, %d", ALUOp, funct3, opb5, funct7b5);

                        $display(" outputs = %b (%b expected)", ALUControl, ALUControlExpected);
                        errors = errors + 1;
        end

        vectornum = vectornum + 1;

        if (testvectors[vectornum] === 10'bx) begin

                $display("%d tests completed with %d errors", vectornum, errors);
                $stop; 
        end
 end

endmodule