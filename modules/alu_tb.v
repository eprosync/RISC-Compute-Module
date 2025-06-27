`timescale 1ns / 1ps

module alu_tb;
  // Declare inputs and outputs
  reg Clock, Clear;
  reg [31:0] A_in, B_in;
  reg [4:0] Control;
  wire [63:0] C_out;

  // Instantiate module under test
  ALU_32 dut(
    .Clock(Clock),
    .Clear(Clear),
    .Control(Control),
    .reg_A(A_in),
    .reg_B(B_in),
    .reg_C(C_out)
  );

  // Initialize inputs
  initial begin
    // this is just to make sure switching control works
    A_in = 32'h00000004;
    B_in = 32'h00000004;
    Control = 5'b00000;
	 
    #10;
	 
    A_in = 32'h00000004;
    B_in = 32'h00000004;
    Control = 5'b00001;

    #10;
  end
endmodule