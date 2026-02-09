module system (
    input logic clk,
    input logic reset
);

logic [31:0] instruction_address;
logic [31:0] instruction_data;

// memory 
unclocked_ro_mem #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .MEM_DEPTH_BYTES(1024),
    .INIT_FILE("init.mem")
) instruction_memory (
    .addr(instruction_address),  // Example address, modify as needed
    .data_out(instruction_data)    // Connect to CPU or other module as needed
);

// cpu
    // Instantiate the CPU module
cpu cpu_inst (
        .clk(clk),
        .reset(reset),
        .instruction_data(instruction_data),
        .instruction_address(instruction_address)
    );

endmodule
