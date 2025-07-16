module register_64_tb;

	// Declare inputs and outputs
	reg [63:0] D;
	reg clr, clk, wr;
	wire [63:0] Q;

	// Instantiate module under test
	register_64 dut(
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
		D = 64'b0;
			
		clk = 1; #10;
		clk = 0; #10;

		D = 64'h0006_0000_0003;
		wr = 1;
			
		clk = 1; #10;
		clk = 0; #10;

		D = 64'h0000_0006;
		wr = 1;
			
		clk = 1; #10;
		clk = 0; #10;

		clr = 1;

		clk = 1; #10;
	end
endmodule
