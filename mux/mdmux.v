module mdmux(
        input [31:0] bmux_out,
        input [31:0] mem_in,
        input rd_en,
        output reg [31:0] MDR_out
    );

    always @ (*) begin
        if (rd_en) begin
            MDR_out = mem_in;
        end else begin
            MDR_out = bmux_out;
        end
    end
endmodule