// RAM - Random Access Memory
// For now I am using this to store instructions, making it a unified memory...
// We should have an I-memory and D-memory instead for this honestly and just map it as an address space thingy internally
// Right now this follows Von Neumann arch, which is unified memory
// For seperate cache/memory it would be Harvard arch

module RAM_32(
        input Clock,
        input Read, Write,
        input [15:0] Address,
        input [31:0] DataIn,
        output [31:0] DataOut
    );

    // This just means each element is stored under a 32-bit address
    // and 511 downto 0 is just the depth
    reg [31:0] memory [511:0];

    initial begin
        // Use this to write some initial data to the memory blocks here
        // EX:
        memory[0] = 32'h08800002; // ldi R1, 2 ; R1 = 2
    end

    reg [31:0] data = 32'b0;
    always @(negedge Clock) begin
        if (Address < 512) begin // 512 can only be mapped to a 9-bit address (so this is for now)
            if (Write && Read) begin
                $display("[RAM] Warning: Simultaneous read/write at %h!", Address);
                // ^ This should never happen... but it can... idk
            end else if (Write) begin
                memory[Address] <= DataIn;
                $display("%0t [RAM] Writing... %h @ %h", $time, DataIn, Address);
            end else if (Read) begin
                data <= memory[Address];
                $display("%0t [RAM] Reading... %h @ %h", $time, memory[Address], Address);
            end
        end else if (Write || Read) begin
            $display("[RAM] Error: Address %h out of range!", Address);
            // ^ This should also never happen...
        end
    end
    assign DataOut = data;
endmodule