module busmux_encoder(
        // general registers
        input R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15,
        // special registers
        input HI, LO, ZHI, ZLO, PC, MDR, InPort, C,
        output reg [4:0] ctrl
    );

    always @ (*) begin
		  ctrl = 5'b00000;
        if (R0) ctrl = 5'b00000;
        else if (R1) ctrl = 5'b00001;
        else if (R2) ctrl = 5'b00010;
        else if (R3) ctrl = 5'b00011;
        else if (R4) ctrl = 5'b00100;
        else if (R5) ctrl = 5'b00101;
        else if (R6) ctrl = 5'b00110;
        else if (R7) ctrl = 5'b00111;
        else if (R8) ctrl = 5'b01000;
        else if (R9) ctrl = 5'b01001;
        else if (R10) ctrl = 5'b01010;
        else if (R11) ctrl = 5'b01011;
        else if (R12) ctrl = 5'b01100;
        else if (R13) ctrl = 5'b01101;
        else if (R14) ctrl = 5'b01110;
        else if (R15) ctrl = 5'b01111;
        else if (HI) ctrl = 5'b10000;
        else if (LO) ctrl = 5'b10001;
        else if (ZHI) ctrl = 5'b10010;
        else if (ZLO) ctrl = 5'b10011;
        else if (PC) ctrl = 5'b10100;
        else if (MDR) ctrl = 5'b10101;
        else if (InPort) ctrl = 5'b10110;
        else if (C) ctrl = 5'b10111;
    end

endmodule

module busmux(
        // general registers
        input [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15,
        // special registers
        input [31:0] HI, LO, ZHI, ZLO, PC, MDR, InPort, C,
        input [4:0] ctrl,
        output [31:0] bmux_out
    );

    reg [31:0] mux;

    always @ (*) begin
        $display("%0t [BusMux] State %b", $time, ctrl);
        case(ctrl)
            5'b00000: mux = R0;
            5'b00001: mux = R1;
            5'b00010: mux = R2;
            5'b00011: mux = R3;
            5'b00100: mux = R4;
            5'b00101: mux = R5;
            5'b00110: mux = R6;
            5'b00111: mux = R7;
            5'b01000: mux = R8;
            5'b01001: mux = R9;
            5'b01010: mux = R10;
            5'b01011: mux = R11;
            5'b01100: mux = R12;
            5'b01101: mux = R13;
            5'b01110: mux = R14;
            5'b01111: mux = R15;
            5'b10000: mux = HI;
            5'b10001: mux = LO;
            5'b10010: mux = ZHI;
            5'b10011: mux = ZLO;
            5'b10100: mux = PC;
            5'b10101: mux = MDR;
            5'b10110: mux = InPort;
            5'b10111: mux = C;
            default: mux = 32'h0;
        endcase
    end

    assign bmux_out = mux;
endmodule