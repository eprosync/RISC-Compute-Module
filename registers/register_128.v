// General 128-bit register
// For stuff like this we would use a splitter to HI/LO wires
module register_128(input [127:0] D, input clk, clr, wr, output reg [127:0] Q);
    initial Q = 128'b0;

    always @ (posedge clk)
    begin
        if (clr) begin
            Q = 128'b0;
        end else if (wr) begin
            Q = D;
        end
    end
endmodule