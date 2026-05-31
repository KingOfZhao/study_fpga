`timescale 1ns/1ps
module sigma_delta_dac_tb;
    localparam N = 8;
    reg clk = 0, rst_n;
    reg  [N-1:0] level;
    wire bitstream;
    integer errors = 0;
    integer ones, i, expect_ones;

    sigma_delta_dac #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .level(level), .bitstream(bitstream));
    always #5 clk = ~clk;

    task measure(input [N-1:0] lv);
        begin
            level = lv;
            // 稳定几拍
            repeat (8) @(negedge clk);
            ones = 0;
            for (i = 0; i < 4096; i = i + 1) begin
                @(negedge clk);
                if (bitstream) ones = ones + 1;
            end
            expect_ones = (lv * 4096) / 256;
            if (ones < expect_ones - 60 || ones > expect_ones + 60) begin
                errors = errors + 1;
                $display("  level=%0d ones=%0d 期望≈%0d", lv, ones, expect_ones);
            end else
                $display("  level=%0d -> 密度=%0d/4096 (期望≈%0d)", lv, ones, expect_ones);
        end
    endtask

    initial begin
        $dumpfile("sigma_delta_dac_tb.vcd");
        $dumpvars(0, sigma_delta_dac_tb);
        rst_n = 0; level = 0;
        @(negedge clk); rst_n = 1;
        measure(8'd64);
        measure(8'd192);
        measure(8'd128);
        if (errors == 0) $display("[PASS] sigma_delta_dac: 比特流平均密度与 level 成正比");
        else             $display("[FAIL] sigma_delta_dac: %0d 处错误", errors);
        $finish;
    end

    initial begin #2000000; $display("[FAIL] sigma_delta_dac: 超时"); $finish; end
endmodule
