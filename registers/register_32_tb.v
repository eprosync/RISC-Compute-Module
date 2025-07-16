module register_32_tb;

	// Declare inputs and outputs
	reg [31:0] D;
	reg clr, clk, wr;
	wire [31:0] Q;

	// Instantiate module under test
	register_32 dut(
		.D(D),
		.clr(clr),
		.clk(clk),
		.wr(wr),
		.Q(Q)
	);

	// Initialize inputs
	initial begin
		clk = 0;
		wr = 0;
		clr = 0;
		D = 32'h0000_0000;
			
		clk = 1; #10;
		clk = 0; #10;

		D = 32'h0000_0003;
		wr = 1;
			
		clk = 1; #10;
		clk = 0; #10;

		D = 32'h0000_0003;
		wr = 1;
			
		clk = 1; #10;
		clk = 0; #10;

		clr = 1;

		clk = 1; #10;
	end
endmodule
