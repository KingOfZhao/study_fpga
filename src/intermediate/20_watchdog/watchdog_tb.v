`timescale 1ns/1ps
module watchdog_tb;
    localparam TIMEOUT = 16;
    reg clk = 0, rst_n, kick;
    wire timeout;
    integer errors = 0;
    integer i, tcount = 0;

    watchdog #(.TIMEOUT(TIMEOUT)) dut (.clk(clk), .rst_n(rst_n), .kick(kick), .timeout(timeout));
    always #5 clk = ~clk;

    always @(posedge clk) if (timeout) tcount = tcount + 1;

    initial begin
        $dumpfile("watchdog_tb.vcd");
        $dumpvars(0, watchdog_tb);
        rst_n = 0; kick = 0;
        @(negedge clk); rst_n = 1;
        // 阶段1：持续喂狗 40 拍，不应超时
        for (i = 0; i < 40; i = i + 1) begin
            kick = (i % 5 == 0);     // 周期性喂狗（间隔 5 < TIMEOUT）
            @(posedge clk);
        end
        kick = 0;
        if (tcount != 0) begin errors = errors + 1; $display("  喂狗期间不应超时, tcount=%0d", tcount); end
        // 阶段2：停止喂狗，应在 TIMEOUT 拍内超时
        for (i = 0; i < TIMEOUT + 4; i = i + 1) @(posedge clk);
        if (tcount < 1) begin errors = errors + 1; $display("  停止喂狗后未超时"); end
        if (errors == 0) $display("[PASS] watchdog: 喂狗不超时、停喂后超时（共 %0d 次）", tcount);
        else             $display("[FAIL] watchdog: %0d 处错误", errors);
        $finish;
    end
endmodule
