// CU - Control Unit
// This is responsible for actually creating a runtime for instructions
// Providing for things like states n such, just think of it as a giant state-machine of logical inputs

`timescale 1ns / 1ps

module CU(
        // Control Unit Specific
        input clk, rst, stop, clr,
        output reg run,
        
        // Register selector
        output reg Gra, Grb, Grc,
        output reg BA_out, R_in, R_out,
        output reg C_sign_out, // for the C_sign_extended for immediates

        // Program information
        output reg PC_out, PC_in, inc_PC,
        output reg IR_out, IR_in,
        inout [31:0] IR,
        output reg CON_FF,
        input branch,

        // This is for Jump Call
        output reg R15_in,

        // ALU
        output reg Y_in, Z_in, ZHI_out, ZLO_out,

        // Memory
        output reg MAR_in, MDR_in,
        output reg MDR_out,
        output reg MEM_rd_en, MEM_wr_en,

        // Specialized Registers
        output reg HI_in, LO_in, HI_out, LO_out,
        output reg OUTPORT_in, INPORT_out, INPORT_in,

        // Debug
        output reg [7:0] present_state
    );

    parameter
        state_reset = 8'b0,

        inst_fetch_PC = 8'b1,
        inst_fetch_READ = 8'b10,
        inst_fetch_IR = 8'b11,

        op_ld_T0 = 8'b100,
        op_ld_T1 = 8'b101,
        op_ld_T2 = 8'b110,
        op_ld_T3 = 8'b111,
        op_ld_T4 = 8'b1000,

        op_ldi_T0 = 8'b1001,
        op_ldi_T1 = 8'b1010,
        op_ldi_T2 = 8'b1011,

        op_st_T0 = 8'b1100,
        op_st_T1 = 8'b1101,
        op_st_T2 = 8'b1110,
        op_st_T3 = 8'b1111,
        op_st_T4 = 8'b10000,

        op_add_T0 = 8'b10001,
        op_add_T1 = 8'b10010,
        op_add_T2 = 8'b10011,

        op_sub_T0 = 8'b10101,
        op_sub_T1 = 8'b10110,
        op_sub_T2 = 8'b10111,

        op_and_T0 = 8'b11000,
        op_and_T1 = 8'b11001,
        op_and_T2 = 8'b11010,

        op_or_T0 = 8'b11011,
        op_or_T1 = 8'b11100,
        op_or_T2 = 8'b11101,

        op_shr_T0 = 8'b11110,
        op_shr_T1 = 8'b11111,
        op_shr_T2 = 8'b100000,

        op_shra_T0 = 8'b100001,
        op_shra_T1 = 8'b100010,
        op_shra_T2 = 8'b100011,

        op_shl_T0 = 8'b100100,
        op_shl_T1 = 8'b100101,
        op_shl_T2 = 8'b100110,

        op_ror_T0 = 8'b100111,
        op_ror_T1 = 8'b101000,
        op_ror_T2 = 8'b101001,

        op_rol_T0 = 8'b101010,
        op_rol_T1 = 8'b101011,
        op_rol_T2 = 8'b101100,

        op_addi_T0 = 8'b101101,
        op_addi_T1 = 8'b101110,
        op_addi_T2 = 8'b101111,

        op_andi_T0 = 8'b110000,
        op_andi_T1 = 8'b110001,
        op_andi_T2 = 8'b110010,

        op_ori_T0 = 8'b110011,
        op_ori_T1 = 8'b110100,
        op_ori_T2 = 8'b110101,

        op_mul_T0 = 8'b110110,
        op_mul_T1 = 8'b110111,
        op_mul_T2 = 8'b111000,
        op_mul_T3 = 8'b111001,

        op_div_T0 = 8'b111010,
        op_div_T1 = 8'b111011,
        op_div_T2 = 8'b111100,
        op_div_T3 = 8'b111101,

        op_neg_T0 = 8'b111110,
        op_neg_T1 = 8'b111111,

        op_not_T0 = 8'b1000000,
        op_not_T1 = 8'b1000001,

        op_br_T0 = 8'b1000010,
        op_br_T1 = 8'b1000011,
        op_br_T2 = 8'b1000100,
        op_br_T3 = 8'b1000101,

        op_jr_T0 = 8'b1000110,

        op_jal_T0 = 8'b1000111,
        op_jal_T1 = 8'b1001000,

        op_in_T0 = 8'b1001001,
        op_out_T0 = 8'b1001010,
        op_mfhi_T0 = 8'b1001011,
        op_mflo_T0 = 8'b1001100,

        op_halt_T0 = 8'b1001101,
        op_nop_T0 = 8'b1001110;

    initial begin
        present_state = state_reset;
    end

        // state machine
    always @ (posedge clk, posedge rst, posedge stop) 
    begin
        if (rst) begin
            present_state = inst_fetch_PC;
        end
        if (stop) begin
            present_state = op_halt_T0;
        end
        case (present_state)
            state_reset : present_state = inst_fetch_PC;

            inst_fetch_PC : present_state = inst_fetch_READ;
            inst_fetch_READ : present_state = inst_fetch_IR;
            inst_fetch_IR : begin @ (posedge clk);
                // after fetching IR we need to decide what operation we will do
                $display("%0t [Control Unit] Choosing by %b", $time, IR[31:27]);
                case (IR[31:27])
                    5'b0 : present_state = op_ld_T0;
                    5'b1 : present_state = op_ldi_T0;
                    5'b10 : present_state = op_st_T0;
                    5'b11 : present_state = op_add_T0;
                    5'b100 : present_state = op_sub_T0;
                    5'b101 : present_state = op_and_T0;
                    5'b110 : present_state = op_or_T0;
                    5'b111 : present_state = op_shr_T0;
                    5'b1000 : present_state = op_shra_T0;
                    5'b1001 : present_state = op_shl_T0;
                    5'b1010 : present_state = op_ror_T0;
                    5'b1011 : present_state = op_rol_T0;
                    5'b1100 : present_state = op_addi_T0;
                    5'b1101 : present_state = op_andi_T0;
                    5'b1110 : present_state = op_ori_T0;
                    5'b1111 : present_state = op_mul_T0;
                    5'b10000 : present_state = op_div_T0;
                    5'b10001 : present_state = op_neg_T0;
                    5'b10010 : present_state = op_not_T0;
                    5'b10011 : present_state = op_br_T0;
                    5'b10100 : present_state = op_jr_T0;
                    5'b10101 : present_state = op_jal_T0;
                    5'b10110 : present_state = op_in_T0;
                    5'b10111 : present_state = op_out_T0;
                    5'b11000 : present_state = op_mfhi_T0;
                    5'b11001 : present_state = op_mflo_T0;
                    5'b11010 : present_state = op_nop_T0;
                    5'b11011 : present_state = op_halt_T0;
                    default : begin
                        present_state = op_halt_T0;
                        #1 $display("%0t [Control Unit] Error: Operation not found! -> %b\nHalting procedure!", $time, IR[31:27]);
                    end
                endcase
            end

            op_ld_T0 : present_state = op_ld_T1;
            op_ld_T1 : present_state = op_ld_T2;
            op_ld_T2 : present_state = op_ld_T3;
            op_ld_T3 : present_state = op_ld_T4;
            op_ld_T4 : present_state = inst_fetch_PC;
        
            op_ldi_T0 : present_state = op_ldi_T1;
            op_ldi_T1 : present_state = op_ldi_T2;
            op_ldi_T2 : present_state = inst_fetch_PC;
        
            op_st_T0 : present_state = op_st_T1;
            op_st_T1 : present_state = op_st_T2;
            op_st_T2 : present_state = op_st_T3;
            op_st_T3 : present_state = op_st_T4;
            op_st_T4 : present_state = inst_fetch_PC;
        
            op_add_T0 : present_state = op_add_T1;
            op_add_T1 : present_state = op_add_T2;
            op_add_T2 : present_state = inst_fetch_PC;
        
            op_sub_T0 : present_state = op_sub_T1;
            op_sub_T1 : present_state = op_sub_T2;
            op_sub_T2 : present_state = inst_fetch_PC;
        
            op_and_T0 : present_state = op_and_T1;
            op_and_T1 : present_state = op_and_T2;
            op_and_T2 : present_state = inst_fetch_PC;
        
            op_or_T0 : present_state = op_or_T1;
            op_or_T1 : present_state = op_or_T2;
            op_or_T2 : present_state = inst_fetch_PC;
        
            op_shr_T0 : present_state = op_shr_T1;
            op_shr_T1 : present_state = op_shr_T2;
            op_shr_T2 : present_state = inst_fetch_PC;
        
            op_shra_T0 : present_state = op_shra_T1;
            op_shra_T1 : present_state = op_shra_T2;
            op_shra_T2 : present_state = inst_fetch_PC;
        
            op_shl_T0 : present_state = op_shl_T1;
            op_shl_T1 : present_state = op_shl_T2;
            op_shl_T2 : present_state = inst_fetch_PC;
        
            op_ror_T0 : present_state = op_ror_T1;
            op_ror_T1 : present_state = op_ror_T2;
            op_ror_T2 : present_state = inst_fetch_PC;
        
            op_rol_T0 : present_state = op_rol_T1;
            op_rol_T1 : present_state = op_rol_T2;
            op_rol_T2 : present_state = inst_fetch_PC;
        
            op_addi_T0 : present_state = op_addi_T1;
            op_addi_T1 : present_state = op_addi_T2;
            op_addi_T2 : present_state = inst_fetch_PC;
        
            op_andi_T0 : present_state = op_andi_T1;
            op_andi_T1 : present_state = op_andi_T2;
            op_andi_T2 : present_state = inst_fetch_PC;
        
            op_ori_T0 : present_state = op_ori_T1;
            op_ori_T1 : present_state = op_ori_T2;
            op_ori_T2 : present_state = inst_fetch_PC;
        
            op_mul_T0 : present_state = op_mul_T1;
            op_mul_T1 : present_state = op_mul_T2;
            op_mul_T2 : present_state = op_mul_T3;
            op_mul_T3 : present_state = inst_fetch_PC;
        
            op_div_T0 : present_state = op_div_T1;
            op_div_T1 : present_state = op_div_T2;
            op_div_T2 : present_state = op_div_T3;
            op_div_T3 : present_state = inst_fetch_PC;
        
            op_neg_T0 : present_state = op_neg_T1;
            op_neg_T1 : present_state = inst_fetch_PC;
        
            op_not_T0 : present_state = op_not_T1;
            op_not_T1 : present_state = inst_fetch_PC;
        
            op_br_T0 : present_state = op_br_T1;
            op_br_T1 : present_state = op_br_T2;
            op_br_T2 : present_state = op_br_T3;
            op_br_T3 : present_state = inst_fetch_PC;

            op_jr_T0 : present_state = inst_fetch_PC;

            op_jal_T0 : present_state = op_jal_T1;
            op_jal_T1 : present_state = inst_fetch_PC;

            op_in_T0 : present_state = inst_fetch_PC;
            op_out_T0 : present_state = inst_fetch_PC;
            op_mflo_T0 : present_state = inst_fetch_PC;
            op_mfhi_T0 : present_state = inst_fetch_PC;

            // op_halt_T0 : present_state = inst_fetch_PC;
            op_nop_T0 : present_state = inst_fetch_PC;
        endcase
    end

    // logic machine, handles logic when state changes
    always @ (present_state)
    begin
        case (present_state)
            state_reset : begin
                run <= 1; // we are now running!

                // Register selector
                Gra <= 0; Grb <= 0; Grc <= 0;
                BA_out <= 0; R_in <= 0; R_out <= 0;
                C_sign_out <= 0; // for the C_sign_extended for immediates

                // Program information
                PC_out <= 0; IR_out <= 0; PC_in <= 0; IR_in <= 0;
                inc_PC <= 0;

                // For jal instruction
                R15_in <= 0;

                // ALU
                Y_in <= 0; Z_in <= 0;
                ZHI_out <= 0; ZLO_out <= 0;

                // Memory
                MAR_in <= 0; MDR_in <= 0;
                MDR_out <= 0;
                MEM_rd_en <= 0; MEM_wr_en <= 0;

                // Special registers
                HI_in <= 0; LO_in <= 0; HI_out <= 0; LO_out <= 0;
                OUTPORT_in <= 0; INPORT_out <= 0; INPORT_in <= 0;

                $display("%0t [Control Unit] rst Cleaned!", $time);
            end

            // Startup of instructions
            inst_fetch_PC: begin
                // Register selector
                Gra <= 0; Grb <= 0; Grc <= 0;
                BA_out <= 0; R_in <= 0; R_out <= 0;
                C_sign_out <= 0; // for the C_sign_extended for immediates

                // Program information
                PC_out <= 0; IR_out <= 0; PC_in <= 0; IR_in <= 0;
                inc_PC <= 0;

                // For jal instruction
                R15_in <= 0;

                // ALU
                Y_in <= 0; Z_in <= 0;
                ZHI_out <= 0; ZLO_out <= 0;
                // Control <= 5'b0; // responsible for which ALU instruction

                // Memory
                MAR_in <= 0; MDR_in <= 0;
                MDR_out <= 0;
                MEM_rd_en <= 0; MEM_wr_en <= 0;

                // Special registers
                HI_in <= 0; LO_in <= 0; HI_out <= 0; LO_out <= 0;
                OUTPORT_in <= 0; INPORT_out <= 0; INPORT_in <= 0;
                inc_PC <= 1;
                PC_out <= 1; MAR_in <= 1; Z_in <= 1;
                // ^ tell ALU to add +1 to PC

                $display("%0t [Control Unit] Start Cleaned!", $time);
            end

            inst_fetch_READ: begin
                ZLO_out <= 1; PC_in <= 1;
                PC_out <= 0; MAR_in <= 0; inc_PC <= 0; Z_in <= 0;
                MEM_rd_en <= 1; MDR_in <= 1;
                // return from ALU the PC + 1 and write it to the PC register
                // at the same time the original PC from isnt_fetch_PC should be in MAR to read from RAM the instructions
            end

            inst_fetch_IR: begin
                ZLO_out <= 0; PC_in <= 0; MDR_in <= 0; MEM_rd_en <= 0;
                MDR_out <= 1; IR_in <= 1;
            end

            // load
            op_ld_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Grb <= 1; BA_out <= 1; Y_in <= 1;
                $display("%0t [Control Unit] Instruction ld", $time);
            end

            op_ld_T1: begin
                Grb <= 0; BA_out <= 0; Y_in <= 0;
                C_sign_out <= 1; Z_in <= 1;
            end

            op_ld_T2: begin
                C_sign_out <= 0; Z_in <= 0;
			    ZLO_out <= 1; MAR_in <= 1;
            end

            op_ld_T3: begin
			    ZLO_out <= 0; MAR_in <= 0;
                MDR_in <= 1; MEM_rd_en <= 1;
            end

            op_ld_T4: begin
                MEM_rd_en <= 0; MDR_in <= 0;
			    MDR_out <= 1; Gra <= 1; R_in <= 1;
            end

            // loadi
            op_ldi_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Grb <= 1; BA_out <= 1; Y_in <= 1;
                $display("%0t [Control Unit] Instruction ldi", $time);
            end

            op_ldi_T1: begin
                Grb <= 0; BA_out <= 0; Y_in <= 0;
                C_sign_out <= 1; Z_in <= 1;
            end

            op_ldi_T2: begin
                C_sign_out <= 0; Z_in <= 0;
                ZLO_out <= 1; Gra <= 1; R_in <= 1;
            end

            // store
            op_st_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Grb <= 1; BA_out <= 1; Y_in <= 1;
                $display("%0t [Control Unit] Instruction st", $time);
            end

            op_st_T1: begin
                Grb <= 0; BA_out <= 0; Y_in <= 0;
                C_sign_out <= 1; Z_in <= 1;
            end

            op_st_T2: begin
                C_sign_out <= 0; Z_in <= 0;
			    ZLO_out <= 1; MAR_in <= 1;
            end

            op_st_T3: begin
			    ZLO_out <= 0; MAR_in <= 0;
                MDR_in <= 1; Gra <= 1; R_out <= 1;
            end

            op_st_T4: begin
                MDR_in <= 0; Gra <= 0; R_out <= 0;
			    MEM_wr_en <= 1; 
            end

            // add, sub
            op_add_T0, op_sub_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Grb <= 1; R_out <= 1; Y_in <= 1;
                $display("%0t [Control Unit] Instruction add/sub", $time);
            end

            op_add_T1, op_sub_T1: begin
                Grb <= 0; R_out <= 0; Y_in <= 0;
                Grc <= 1; R_out <= 1; Z_in <= 1;
            end

            op_add_T2, op_sub_T2: begin
                Grc <= 0; R_out <= 0; Z_in <= 0;
                ZLO_out <= 1; Gra <= 1; R_in <= 1;
            end

            // and, or, shr, shra, shl, ror, rol
            op_and_T0, op_or_T0, op_shr_T0, op_shra_T0, op_shl_T0, op_ror_T0, op_rol_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Grb <= 1; R_out <= 1; Y_in <= 1;
                $display("%0t [Control Unit] Instruction add/or/shr/shra/shl/ror/rol", $time);
            end

            op_and_T1, op_or_T1, op_shr_T1, op_shra_T1, op_shl_T1, op_ror_T1, op_rol_T1: begin
                Grb <= 0; R_out <= 0; Y_in <= 0;
                Grc <= 1; R_out <= 1; Z_in <= 1;
            end

            op_and_T2, op_or_T2, op_shr_T2, op_shra_T2, op_shl_T2, op_ror_T2, op_rol_T2: begin
                Grc <= 0; R_out <= 0; Z_in <= 0;
                Gra <= 1; R_in <= 1; ZLO_out <= 1;
            end

            // mul, div
            op_mul_T0, op_div_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Gra <= 1; R_out <= 1; Y_in <= 1;
                $display("%0t [Control Unit] Instruction mul/div", $time);
            end

            op_mul_T1, op_div_T1: begin
                Gra <= 0; R_out <= 0; Y_in <= 0;
                Grb <= 1; R_out <= 1; Z_in <= 1;
            end

            op_mul_T2, op_div_T2: begin
                Grb <= 0; R_out <= 0; Z_in <= 0;
                LO_in <= 1; ZLO_out <= 1;
            end

            op_mul_T3, op_div_T3: begin
                LO_in <= 0; ZLO_out <= 0;
                HI_in <= 1; ZHI_out <= 1;
            end

            // neg, not
            op_neg_T0, op_not_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Grb <= 1; R_out <= 1; Z_in <= 1;
                $display("%0t [Control Unit] Instruction neg/not", $time);
            end

            op_neg_T1, op_not_T1: begin
                Grb <= 0; R_out <= 0; Z_in <= 0;
                Gra <= 1; R_in <= 1; ZLO_out <= 1;
            end

            // addi, andi, ori
            op_addi_T0, op_andi_T0, op_ori_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Grb <= 1; R_out <= 1; Y_in <= 1;
                $display("%0t [Control Unit] Instruction addi/andi/ori", $time);
            end

            op_addi_T1, op_andi_T1, op_ori_T1: begin
                Grb <= 0; R_out <= 0; Y_in <= 0;
                C_sign_out <= 1; Z_in <= 1;
            end

            op_addi_T2, op_andi_T2, op_ori_T2: begin
                C_sign_out <= 0; Z_in <= 0;
                Gra <= 1; R_in <= 1; ZLO_out <= 1;
            end

            // jr
            op_jr_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Gra <= 1; R_out <= 1; PC_in <= 1;
                $display("%0t [Control Unit] Instruction jr", $time);
            end

            // jal (come back to this)
            op_jal_T0: begin
                MDR_out <= 0; IR_in <= 0;
                PC_out <= 1; R15_in <= 1;
                // IR_copy <= {IR[31:23], IR[22:0] | 9'b1111_0000_0000}; // overwrite Grb to target 15'th register
                // in call instructions we typically need to target registers that are least to be touched, R0 is an exception
                $display("%0t [Control Unit] Instruction jal", $time);
            end

            op_jal_T1: begin
                R15_in <= 0; PC_out <= 0;
                Gra <= 1; R_out <= 1; PC_in <= 1;
            end

            // mfhi
            op_mfhi_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Gra <= 1; R_in <= 1; HI_out <= 1;
                $display("%0t [Control Unit] Instruction mfhi", $time);
            end

            // mflo
            op_mflo_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Gra <= 1; R_in <= 1; LO_out <= 1;
                $display("%0t [Control Unit] Instruction mflo", $time);
            end

            // in
            op_in_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Gra <= 1; R_in <= 1; INPORT_out <= 1;
                $display("%0t [Control Unit] Instruction in", $time);
            end

            // out
            op_out_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Gra <= 1; R_out <= 1; OUTPORT_in <= 1;
                $display("%0t [Control Unit] Instruction out", $time);
            end

            // br
            op_br_T0: begin
                MDR_out <= 0; IR_in <= 0;
                Gra <= 1; R_out <= 1; CON_FF <= 1;
                $display("%0t [Control Unit] Instruction br", $time);
            end

            op_br_T1: begin
                Gra <= 0; R_out <= 0; CON_FF <= 0;
                PC_out <= 1; Y_in <= 1;
            end

            op_br_T2: begin
                PC_out <= 0; Y_in <= 0;
                C_sign_out <= 1; Z_in <= 1;
            end

            op_br_T3: begin
                C_sign_out <= 0; Z_in <= 0;
                ZLO_out <= 1; PC_in <= 1;
            end
            
            // nop & halt
            op_halt_T0 : begin
                run <= 0;
                $display("%0t [Control Unit] Instruction halt", $time);
            end
            op_nop_T0 : begin
                $display("%0t [Control Unit] Instruction nop", $time);
            end
            default : begin end
        endcase
    end
endmodule