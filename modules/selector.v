module selector_decoder(input [3:0] dec_in, output reg [15:0] dec_out);
    always @ (*)
    begin
        case(dec_in)
            4'b0000 : dec_out = 16'h0001; // R0
            4'b0001 : dec_out = 16'h0002; // R1
            4'b0010 : dec_out = 16'h0004; // R2
            4'b0011 : dec_out = 16'h0008; // R3
            4'b0100 : dec_out = 16'h0010; // R4
            4'b0101 : dec_out = 16'h0020; // R5
            4'b0110 : dec_out = 16'h0040; // R6
            4'b0111 : dec_out = 16'h0080; // R7
            4'b1000 : dec_out = 16'h0100; // R8
            4'b1001 : dec_out = 16'h0200; // R9
            4'b1010 : dec_out = 16'h0400; // R10
            4'b1011 : dec_out = 16'h0800; // R11
            4'b1100 : dec_out = 16'h1000; // R12
            4'b1101 : dec_out = 16'h2000; // R13
            4'b1110 : dec_out = 16'h4000; // R14
            4'b1111 : dec_out = 16'h8000; // R15
            default : dec_out = 16'b0;
        endcase
    end
endmodule

module selector_encoder(
        input Gra, Grb, Grc, R_in, R_out, BA_out,
        input [31:0] IR, // this is our instruction
        output [31:0] C_sign_extended, // this is the immediate
        output [15:0] Rin_cs, Rout_cs, // this is the control signals for each register 0-15
        input R15_in // jal special case
    );

    wire [3:0] Opcode;
    wire [3:0] dec_in;
    wire [15:0] dec_out;

    // {4{wire}} means convert from 1 to 4
    assign opcode = IR[31:27];
    assign dec_in = (IR[26:23] & {4{Gra}}) | (IR[22:19] & {4{Grb}}) | (IR[18:15] & {4{Grc}});
    // ^ think of this as selected from and R1, R2, R3
    // Gra = R1, Grb = R2, Grc = R3
    // This is simply to decide on which register to chose from in the instruction

    // this is a 4 to 16 decoder
    selector_decoder decoder(dec_in, dec_out);

    // extracts the 18 downto 0 immediate, but also if the 18'th bit is 1 then the upper 13 will be 1
    assign C_sign_extended = {{13{IR[18]}},IR[18:0]};
    assign Rin_cs = ({16{R_in}} & dec_out) | ({16{R15_in}} & 16'h8000);
    assign Rout_cs = ({16{R_out}} | {16{BA_out}}) & dec_out;
endmodule