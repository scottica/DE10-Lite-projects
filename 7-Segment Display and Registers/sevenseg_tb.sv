module sevenseg_tb;

    logic clk, reset;
    logic [3:0] data;               // input digit (0-F)
    logic [6:0] segments;           // DUT output
    logic [6:0] exp_segments;       // expected output from .tv
    logic [31:0] vectornum, errors;
    logic [10:0] testvectors[10000:0]; // [10:7]=expected, [3:0]=input

    // DUT instance
    sevenseg dut (.data(data), .segments(segments));

    // clock generator
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // load vectors and init
    initial begin
        $readmemh("sevenseg.tv", testvectors);
        vectornum = 0;
        errors = 0;

        reset = 1; #22;
        reset = 0;
    end

    // apply test vectors at posedge
    always @(posedge clk) begin
        #1;
        {exp_segments, data} = testvectors[vectornum];
    end

    // check results at negedge
    always @(negedge clk) begin
        if (~reset) begin
            if (segments !== exp_segments) begin
                $display("Error at vector %0d: input=%h expected=%07b got=%07b",
                         vectornum, data, exp_segments, segments);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;

            if (testvectors[vectornum] === 11'bx) begin
                $display("%0d tests completed with %0d errors",
                         vectornum, errors);
                $stop;
            end
        end
    end

endmodule

