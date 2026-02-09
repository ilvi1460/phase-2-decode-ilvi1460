module system_tb;

    logic clk;
    logic rst;

    // Instantiate the system module
    system dut (
        .clk(clk),
        .reset(rst)
    );

    initial begin
        $dumpfile("simulation_results.vcd"); // Name of the output file
        $dumpvars(0, system_tb);                // Dump all signals in tb_top and below
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Test sequence
    initial begin
        $display("Starting system testbench...");

        // Initialize reset
        rst = 1;
        #10;
        rst = 0; // Release reset

        // Run for a number of clock cycles
        repeat (50) @(posedge clk);

        // Finish simulation
        $finish;
    end


endmodule
