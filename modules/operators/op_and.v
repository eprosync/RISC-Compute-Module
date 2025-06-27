module op_and_64(input [63:0] Ain, Bin, output [63:0] Zout);
    genvar i;
    generate
        for (i=0; i<63; i=i+1) begin : loop
            assign Zout[i] = Ain[i] & Bin[i];
        end
    endgenerate
endmodule

module op_and_32(input [31:0] Ain, Bin, output [31:0] Zout);
    genvar i;
    generate
        for (i=0; i<31; i=i+1) begin : loop
            assign Zout[i] = Ain[i] & Bin[i];
        end
    endgenerate
endmodule