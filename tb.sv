`timescale 1ns/1ps

module tb_c;

    localparam int DATA_W = 32;

    logic clk;
    logic rst_n;

    logic in_valid;
    logic [DATA_W-1:0] in_data;

    logic out_ready;
    logic out_valid;
    logic [DATA_W-1:0] out_data;

    // DUT
    c #(.DATA_W(DATA_W)) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .in_data   (in_data),
        .out_ready (out_ready),
        .out_valid (out_valid),
        .out_data  (out_data)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        in_valid = 0;
        in_data = '0;
        out_ready = 0;

        repeat (2) @(posedge clk);
        rst_n = 1;

        
        $display("TEST 1: load + consume");
        in_valid = 1;
        in_data  = 32'h1111_1111;
        out_ready = 1;

        #20;
        in_valid = 0;
        #20;
        
        $display("TEST 2: backpressure hold");
        in_valid = 1;
        in_data  = 32'hDEAD_BEEF;
        out_ready = 0;

        #20;
        in_valid = 0;
        #20;
        
        $display("TEST 3: release");
        out_ready = 1;
        #20;

        // buffer should now be empty
        in_valid = 1;
        in_data  = 32'h2222_2222;

        #20;
        in_valid = 0;
        #20;

        $display("TEST 4: replace");

        // preload buffer
        in_valid = 1;
        in_data  = 32'hAAAA_AAAA;
        out_ready = 0;
        #20;
        in_valid = 0;
        #20;
        // now replace
        in_valid = 1;
        in_data  = 32'hBBBB_BBBB;
        out_ready = 1;

        #20;
        in_valid = 0;
        #20;
        $finish;
    end

    // Waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_c);
    end

endmodule
