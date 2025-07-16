// This is the datapath, which is a culmination of all modules combined
// In a sense this is where we wire everything up

module datapath(
        input clk, rst, stop, clr,
        output run,
        output wire [31:0] OUTPORT_data_out,
        input wire [31:0] INPORT_data_in,

        // Program Counter & Instruction
        input wire PC_in, PC_out, inc_PC, IR_in,
        output wire [31:0] PC_data_out,

        // Enablers
        output wire [4:0] busmux_selector,
        input wire Gra, Grb, Grc, R_in, R_out, BA_out,
        input wire HI_in, LO_in,

        // Outputers
        input wire HI_out, LO_out, OUTPORT_in, INPORT_out, C_sign_out,
        output wire [31:0] HI_data_out, LO_data_out, INPORT_data_out, C_data_out,

        // ALU
        input wire Y_in, Z_in, ZHI_out, ZLO_out,
        output wire [31:0] Y_data_out,
        output wire [63:0] Z_data_out,
        input wire CON_FF_in,
        output wire branch,

        // Memory Management
        input wire MDR_in, MAR_in, MDR_out, MEM_rd_en, MEM_wr_en,
        input wire [31:0] MEM_data_in, MEM_data_out,
        output wire [31:0] MDR_data_in, MDR_data_out, MAR_data_out,

        // Debug
        output wire [31:0] R0_data_out, R1_data_out, R2_data_out, R3_data_out, R4_data_out, R5_data_out, R6_data_out, R7_data_out, R8_data_out, R9_data_out, R10_data_out, R11_data_out, R12_data_out, R13_data_out, R14_data_out, R15_data_out,
        output wire [31:0] ZHI_data_out, ZLO_data_out, IR_data_out, data_bus,
        output wire [15:0] Rout_cs,
        input wire [15:0] Rin_cs,
        output wire [7:0] present_state,
        output wire R15_in
    );

    // ctrl Unit
    CU CU(
        .clk(clk), .rst(rst), .stop(stop), .clr(clr), .run(run),
        .present_state(present_state),
        
        .PC_out(PC_out), .PC_in(PC_in), .inc_PC(inc_PC),
        .IR_in(IR_in), .IR_out(IR_out), .IR(IR_data_out),

        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .BA_out(BA_out), .R_in(R_in), .R_out(R_out),
        .C_sign_out(C_sign_out),

        .R15_in(R15_in),

        .Y_in(Y_in), .Z_in(Z_in), .ZHI_out(ZHI_out), .ZLO_out(ZLO_out),
        .CON_FF(CON_FF_in),
        .branch(branch),

        .MAR_in(MAR_in), .MDR_in(MDR_in),
        .MDR_out(MDR_out),
        .MEM_rd_en(MEM_rd_en), .MEM_wr_en(MEM_wr_en),

        .HI_in(HI_in), .LO_in(LO_in), .HI_out(HI_out), .LO_out(LO_out),
        .OUTPORT_in(OUTPORT_in), .INPORT_out(INPORT_out), .INPORT_in(INPORT_in)
    );

    // Registers
    register_32 PC(data_bus, clk, clr, PC_in, PC_data_out);
    register_32 IR(data_bus, clk, clr, IR_in, IR_data_out);
    selector_encoder selector_encoder(Gra, Grb, Grc, R_in, R_out, BA_out, IR_data_out, C_data_out, Rin_cs, Rout_cs, R15_in);

    register_R0_32 R0(data_bus, clk, clr, Rin_cs[0], BA_out, R0_data_out);
    register_32 R1(data_bus, clk, clr, Rin_cs[1], R1_data_out);
    register_32 R2(data_bus, clk, clr, Rin_cs[2], R2_data_out);
    register_32 R3(data_bus, clk, clr, Rin_cs[3], R3_data_out);
    register_32 R4(data_bus, clk, clr, Rin_cs[4], R4_data_out);
    register_32 R5(data_bus, clk, clr, Rin_cs[5], R5_data_out);
    register_32 R6(data_bus, clk, clr, Rin_cs[6], R6_data_out);
    register_32 R7(data_bus, clk, clr, Rin_cs[7], R7_data_out);
    register_32 R8(data_bus, clk, clr, Rin_cs[8], R8_data_out);
    register_32 R9(data_bus, clk, clr, Rin_cs[9], R9_data_out);
    register_32 R10(data_bus, clk, clr, Rin_cs[10], R10_data_out);
    register_32 R11(data_bus, clk, clr, Rin_cs[11], R11_data_out);
    register_32 R12(data_bus, clk, clr, Rin_cs[12], R12_data_out);
    register_32 R13(data_bus, clk, clr, Rin_cs[13], R13_data_out);
    register_32 R14(data_bus, clk, clr, Rin_cs[14], R14_data_out);
    register_32 R15(data_bus, clk, clr, Rin_cs[15], R15_data_out);

    // Special Register
    register_32 HI(data_bus, clk, clr, HI_in, HI_data_out);
    register_32 LO(data_bus, clk, clr, LO_in, LO_data_out);
    register_32 INPORT(INPORT_data_in, clk, clr, 1'b1, INPORT_data_out);
    register_32 OUTPORT(data_bus, clk, clr, OUTPORT_in, OUTPORT_data_out);

    // ALU & Logic Section
    cff_logic_32 CONFF(data_bus, IR_data_out[22:19], CON_FF_in, branch);
    register_32 ZHI(Z_data_out[63:32], clk, clr, Z_in, ZHI_data_out);
    register_32 ZLO(Z_data_out[31:0], clk, clr, Z_in, ZLO_data_out);
    register_32 Y(data_bus, clk, clr, Y_in, Y_data_out);
    ALU_32 ALU(
        .clk(clk),
        .clr(clr),
        .branch(branch), 
        .inc_PC(inc_PC), // this just acts as a pass through with + 1
        .ctrl(IR_data_out[31:27]),
        .reg_A(Y_data_out),
        .reg_B(data_bus),
        .reg_C(Z_data_out)
    );

    // Memory Section
    register_32 MDR(MDR_data_in, clk, clr, MDR_in, MDR_data_out);
    register_32 MAR(data_bus, clk, clr, MAR_in, MAR_data_out);
    mdmux mdmux(data_bus, MEM_data_out, MEM_rd_en, MDR_data_in);
    RAM_32 RAM(clk, MEM_rd_en, MEM_wr_en, MAR_data_out[15:0], MDR_data_out, MEM_data_out);

    // data_bus Direction Section
    busmux_encoder busmux_encoder(
        .R0(Rout_cs[0]),
        .R1(Rout_cs[1]),
        .R2(Rout_cs[2]),
        .R3(Rout_cs[3]),
        .R4(Rout_cs[4]),
        .R5(Rout_cs[5]),
        .R6(Rout_cs[6]),
        .R7(Rout_cs[7]),
        .R8(Rout_cs[8]),
        .R9(Rout_cs[9]),
        .R10(Rout_cs[10]),
        .R11(Rout_cs[11]),
        .R12(Rout_cs[12]),
        .R13(Rout_cs[13]),
        .R14(Rout_cs[14]),
        .R15(Rout_cs[15]),

        .HI(HI_out),
        .LO(LO_out),
        .ZHI(ZHI_out),
        .ZLO(ZLO_out),
        .PC(PC_out),
        .MDR(MDR_out),
        .InPort(INPORT_out),
        .C(C_sign_out),

        .ctrl(busmux_selector)
    );

    busmux busmux(
        .R0(R0_data_out),
        .R1(R1_data_out),
        .R2(R2_data_out),
        .R3(R3_data_out),
        .R4(R4_data_out),
        .R5(R5_data_out),
        .R6(R6_data_out),
        .R7(R7_data_out),
        .R8(R8_data_out),
        .R9(R9_data_out),
        .R10(R10_data_out),
        .R11(R11_data_out),
        .R12(R12_data_out),
        .R13(R13_data_out),
        .R14(R14_data_out),
        .R15(R15_data_out),

        .HI(HI_data_out),
        .LO(LO_data_out),
        .ZHI(ZHI_data_out),
        .ZLO(ZLO_data_out),
        .PC(PC_data_out),
        .MDR(MDR_data_out),
        .InPort(INPORT_data_out),
        .C(C_data_out),

        .ctrl(busmux_selector),
        .bmux_out(data_bus)
    );
endmodule