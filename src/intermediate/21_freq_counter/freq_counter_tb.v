`timescale 1ns/1ps
module freq_counter_tb;
    localparam GATE = 100, W = 16;
    reg clk = 0, rst_n, sig;
    wire [W-1:0] freq;
    wire done;
    integer errors = 0;
    reg [W-1:0] result;
    reg got = 0;

    freq_counter #(.GATE(GATE), .W(W)) dut (.clk(clk), .rst_n(rst_n), .sig(sig), .freq(freq), .done(done));
    always #5 clk = ~clk;

    // 输入信号：周期 10 个时钟（高 5 低 5）-> 闸门内约 10 个上升沿
    integer p = 0;
    always @(posedge clk) begin
        p = p + 1;
        sig = (p % 10) < 5;
    end

    always @(posedge clk) if (done && !got) begin got = 1; result = freq; end

    initial begin
        $dumpfile("freq_counter_tb.vcd");
        $dumpvars(0, freq_counter_tb);
        rst_n = 0; sig = 0;
        @(negedge clk); rst_n = 1;
        wait (got);
        // 期望 ≈ GATE/10 = 10（允许 ±1 对齐误差）
        if (result < 9 || result > 11) begin
            errors = errors + 1;
            $display("  测得频率计数=%0d 期望≈10", result);
        end
        if (errors == 0) $display("[PASS] freq_counter: 闸门内测得 %0d 个上升沿（期望≈10）", result);
        else             $display("[FAIL] freq_counter: %0d 处错误", errors);
        $finish;
    end

    initial begin #100000; $display("[FAIL] freq_counter: 超时"); $finish; end
endmodule
