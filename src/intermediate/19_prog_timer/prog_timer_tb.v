`timescale 1ns/1ps
module prog_timer_tb;
    localparam W = 16;
    reg clk = 0, rst_n, load, start, tick;
    reg  [W-1:0] load_val;
    wire [W-1:0] cnt;
    wire running, done;
    integer errors = 0;
    integer ticks_to_done = 0;

    prog_timer #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .load(load), .load_val(load_val),
                             .start(start), .tick(tick), .cnt(cnt), .running(running), .done(done));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("prog_timer_tb.vcd");
        $dumpvars(0, prog_timer_tb);
        rst_n = 0; load = 0; start = 0; tick = 0; load_val = 0;
        @(negedge clk); rst_n = 1;
        // 装载 5
        @(negedge clk); load = 1; load_val = 5; @(negedge clk); load = 0;
        if (cnt !== 5) begin errors = errors + 1; $display("  装载后 cnt=%0d", cnt); end
        // 启动
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        // 给 tick 直到 done
        while (!done && ticks_to_done < 20) begin
            tick = 1; @(posedge clk); #1;
            if (done) ; tick = 0; @(negedge clk);
            ticks_to_done = ticks_to_done + 1;
        end
        if (ticks_to_done !== 5) begin
            errors = errors + 1;
            $display("  done 在第 %0d 个 tick（期望 5）", ticks_to_done);
        end
        if (running) begin errors = errors + 1; $display("  done 后仍 running"); end
        if (errors == 0) $display("[PASS] prog_timer: 装载 5、5 个 tick 后 done 正确");
        else             $display("[FAIL] prog_timer: %0d 处错误", errors);
        $finish;
    end
endmodule
