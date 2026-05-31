`timescale 1ns/1ps
module stopwatch_tb;
    reg clk = 0, rst_n, run, clr, tick;
    wire [3:0] sec_ones, sec_tens, min_ones, min_tens;
    integer errors = 0;
    integer i;

    stopwatch dut (.clk(clk), .rst_n(rst_n), .run(run), .clr(clr), .tick(tick),
                   .sec_ones(sec_ones), .sec_tens(sec_tens),
                   .min_ones(min_ones), .min_tens(min_tens));
    always #5 clk = ~clk;

    task do_tick; begin
        tick = 1; @(posedge clk); #1; tick = 0; @(posedge clk); #1;
    end endtask

    initial begin
        $dumpfile("stopwatch_tb.vcd");
        $dumpvars(0, stopwatch_tb);
        rst_n = 0; run = 0; clr = 0; tick = 0;
        @(negedge clk); rst_n = 1; run = 1;
        // 走 125 秒 -> 02:05
        for (i = 0; i < 125; i = i + 1) do_tick;
        if (!(min_tens==0 && min_ones==2 && sec_tens==0 && sec_ones==5)) begin
            errors = errors + 1;
            $display("  EXPECT 02:05 got %0d%0d:%0d%0d", min_tens, min_ones, sec_tens, sec_ones);
        end
        // clr 清零
        clr = 1; @(posedge clk); #1; clr = 0;
        if (!(min_tens==0 && min_ones==0 && sec_tens==0 && sec_ones==0)) begin
            errors = errors + 1; $display("  clr 未清零");
        end
        if (errors == 0) $display("[PASS] stopwatch: 125 秒计为 02:05 且清零正确");
        else             $display("[FAIL] stopwatch: %0d 处错误", errors);
        $finish;
    end
endmodule
