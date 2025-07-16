// RAM - Random Access Memory
// For now I am using this to store instructions, making it a unified memory...
// We should have an I-memory and D-memory instead for this honestly and just map it as an address space thingy internally
// Right now this follows Von Neumann arch, which is unified memory
// For seperate cache/memory it would be Harvard arch

module RAM_32(
        input clk,
        input rd_en, wr_en,
        input [15:0] addr,
        input [31:0] din,
        output [31:0] dout
    );

    // This just means each element is stored under a 32-bit address
    // and 511 downto 0 is just the depth
    reg [31:0] memory [511:0];

    initial begin
        // Use this to write some initial data to the memory blocks here
        // EX:
        memory[0] = 32'h09000002; // ldi R2, $2
        memory[1] = 32'h09800003; // ldi R3, $3
        memory[2] = 32'h61180004; // addi R2, R3, $4

        memory[3] = 32'h09000002; // ldi R2, $2
        memory[4] = 32'h09800003; // ldi R3, $3
        memory[5] = 32'h69180004; // andi R2, R3, $4

        memory[6] = 32'h09000002; // ldi R2, $2
        memory[7] = 32'h09800003; // ldi R3, $3
        memory[8] = 32'h71180004; // ori R2, R3, $4
    end

    reg [31:0] data = 32'b0;
    always @(negedge clk) begin
        if (addr < 512) begin // 512 can only be mapped to a 9-bit address (so this is for now)
            if (wr_en && rd_en) begin
                $display("[RAM] Warning: Simultaneous read/write at %h!", addr);
                // ^ This should never happen... but it can... idk
            end else if (wr_en) begin
                memory[addr] <= din;
                $display("%0t [RAM] Writing... %h @ %h", $time, din, addr);
            end else if (rd_en) begin
                data <= memory[addr];
                $display("%0t [RAM] Reading... %h @ %h", $time, memory[addr], addr);
            end
        end else if (wr_en || rd_en) begin
            $display("[RAM] Error: addr %h out of range!", addr);
            // ^ This should also never happen...
        end
    end
    assign dout = data;
endmodule