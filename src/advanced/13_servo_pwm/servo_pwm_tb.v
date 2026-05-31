`timescale 1ns/1ps
module servo_pwm_tb;
    localparam PERIOD = 2000, MINP = 100, MAXP = 200;
    reg clk = 0, rst_n;
    reg  [7:0] pos;
    wire pwm;
    integer errors = 0;
    integer high, k, exp_hi;

    servo_pwm #(.PERIOD(PERIOD), .MINP(MINP), .MAXP(MAXP)) dut (
        .clk(clk), .rst_n(rst_n), .pos(pos), .pwm(pwm));
    always #5 clk = ~clk;

    task measure(input [7:0] p);
        begin
            pos = p;
            // 跳过一个周期对齐
            repeat (PERIOD + 10) @(negedge clk);
            high = 0;
            for (k = 0; k < PERIOD; k = k + 1) begin
                @(negedge clk);
                if (pwm) high = high + 1;
            end
            exp_hi = MINP + (p * (MAXP - MINP)) / 255;
            if (high < exp_hi - 3 || high > exp_hi + 3) begin
                errors = errors + 1;
                $display("  pos=%0d high=%0d 期望≈%0d", p, high, exp_hi);
            end else
                $display("  pos=%0d -> 高电平=%0d 拍 (期望≈%0d)", p, high, exp_hi);
        end
    endtask

    initial begin
        $dumpfile("servo_pwm_tb.vcd");
        $dumpvars(0, servo_pwm_tb);
        rst_n = 0; pos = 0;
        @(negedge clk); rst_n = 1;
        measure(8'd0);
        measure(8'd128);
        measure(8'd255);
        if (errors == 0) $display("[PASS] servo_pwm: 高电平宽度随 pos 线性变化");
        else             $display("[FAIL] servo_pwm: %0d 处错误", errors);
        $finish;
    end

    initial begin #2000000; $display("[FAIL] servo_pwm: 超时"); $finish; end
endmodule
