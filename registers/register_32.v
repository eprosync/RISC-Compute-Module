// General 32-bit register
module register_32(input [31:0] D, input clk, clr, wr, output reg [31:0] Q);
    initial Q = 32'b0;

    always @ (posedge clk)
    begin
        if (clr) begin
            Q = 32'b0;
        end else if (wr) begin
            Q = D;
        end
    end
endmodule