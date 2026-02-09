module unclocked_ro_mem 
# (
    parameter ADDR_WIDTH = 32, 
    parameter DATA_WIDTH = 32, 
    parameter MEM_DEPTH_BYTES = 1024,
    parameter INIT_FILE = "init.mem"
)
(
    input logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data_out
);

    // Simple read-only memory initialized with some values
    // iverilog does not support this System Verilog syntax, so need for loop
    // logic [DATA_WIDTH-1:0] rom [0:MEM_DEPTH-1] = '{default: '0};
    logic [7:0] rom [0:MEM_DEPTH_BYTES-1] ;

    localparam WORDS = MEM_DEPTH_BYTES / 4;  // if DATA_WIDTH isn't 32 this needs to be fixed
    reg [DATA_WIDTH:0] temp_word_mem [0:WORDS-1];

    // Initialize ROM with some values
    initial begin
        // initialize all locations to zero
        for (int i = 0; i < WORDS; i++) begin
            temp_word_mem[i] = 0; 
        end 
        // then read in mem contents from file (which might not be all locations)
        $readmemh(INIT_FILE, temp_word_mem);

        // Distribute 32-bit words into 8-bit ROM slots
        for (int i = 0; i < WORDS; i = i + 1) begin
            // Little-endian mapping (adjust order if big-endian is needed)
            rom[i*4 + 0] = temp_word_mem[i][7:0];
            rom[i*4 + 1] = temp_word_mem[i][15:8];
            rom[i*4 + 2] = temp_word_mem[i][23:16];
            rom[i*4 + 3] = temp_word_mem[i][31:24];
        end
    end

    // Combinational read logic
    always_comb begin
        data_out = {rom[addr+3], rom[addr+2], rom[addr+1], rom[addr+0]};
    end

endmodule
