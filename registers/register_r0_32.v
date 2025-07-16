module register_R0_32(input [31:0] D, input clk, clr, wr, BA_out, output [31:0] Q);
    wire [31:0] Q_copy;
    register_32 R0(D, clk, clr, wr, Q_copy);
    assign Q = ({32{!BA_out}} & Q_copy);
endmodule