module register_128_tb;

	// Declare inputs and outputs
	reg [127:0] D;
	reg clr, clk, wr;
	wire [127:0] Q;

	// Instantiate module under test
	register_128 dut(
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
		D = 128'b0;
			
		clk = 1; #10;
		clk = 0; #10;

		D = 128'h0006_0000_0003;
		wr = 1;
			
		clk = 1; #10;
		clk = 0; #10;

		D = 128'h0000_0006;
		wr = 1;
			
		clk = 1; #10;
		clk = 0; #10;

		clr = 1;

		clk = 1; #10;
	end
endmodule
