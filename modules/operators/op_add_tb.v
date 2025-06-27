`timescale 1ns / 1ps

module op_add_32_tb;

  // Declare inputs and outputs
  reg [31:0] Ain, Bin;
  reg Cin;
  wire [31:0] Zout;
  wire Cout;

  // Instantiate module under test
  op_add_32 dut(
    .Ain(Ain),
    .Bin(Bin),
    .Cin(Cin),
    .Zout(Zout),
    .Cout(Cout)
  );

  // Initialize inputs
  initial begin
    Ain = 32'b0001;
    Bin = 32'b0010;
    Cin = 0;
	 
    #10; // 10 nano seconds
	 
    Ain = 32'b10010;
    Bin = 32'b10100;
    Cin = 0;
	 
	#10; // 10 nano seconds
  end
endmodule
