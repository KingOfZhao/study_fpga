`timescale 1ns/1ps
module clock_enable_tb;
    localparam DIV = 10;
    reg clk = 0, rst_n;
    wire tick;
    integer errors = 0;
    integer ticks = 0, cycles = 0;
    integer gap = 0, last = -1;

    clock_enable #(.DIV(DIV)) dut (.clk(clk), .rst_n(rst_n), .tick(tick));
    always #5 clk = ~clk;

    always @(posedge clk) if (rst_n) begin
        cycles = cycles + 1;
        if (tick) begin
            ticks = ticks + 1;
            if (last >= 0) begin
                gap = cycles - last;
                if (gap != DIV) begin errors = errors + 1; $display("  间隔=%0d 期望=%0d", gap, DIV); end
            end
            last = cycles;
        end
    end

    initial begin
        $dumpfile("clock_enable_tb.vcd");
        $dumpvars(0, clock_enable_tb);
        rst_n = 0; @(negedge clk); rst_n = 1;
        repeat (105) @(posedge clk);
        if (ticks < 9) begin errors = errors + 1; $display("  tick 次数过少=%0d", ticks); end
        if (errors == 0) $display("[PASS] clock_enable: 每 %0d 拍 1 次 tick（共 %0d 次）", DIV, ticks);
        else             $display("[FAIL] clock_enable: %0d 处错误", errors);
        $finish;
    end
endmodule
