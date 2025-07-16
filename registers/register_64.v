// General 64-bit register
module register_64(input [63:0] D, input clk, clr, wr, output reg [63:0] Q);
    initial Q = 64'b0;

    always @ (posedge clk)
    begin
        if (clr) begin
            Q = 64'b0;
        end else if (wr) begin
            Q = D;
        end
    end
endmodule