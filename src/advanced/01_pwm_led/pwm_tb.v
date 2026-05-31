// pwm 自校验 testbench：测量一个完整周期内的高电平拍数 == duty
`timescale 1ns/1ps

module pwm_tb;
    localparam WIDTH  = 4;          // 周期 = 16 拍
    localparam PERIOD = (1 << WIDTH);

    reg              clk = 0;
    reg              rst_n;
    reg  [WIDTH-1:0] duty;
    wire             pwm_out;
    integer          errors = 0;

    pwm #(.WIDTH(WIDTH)) dut (.clk(clk), .rst_n(rst_n), .duty(duty), .pwm_out(pwm_out));

    always #5 clk = ~clk;

    // 在任意连续 PERIOD 拍内，cnt 取遍 0..PERIOD-1 各一次，
    // 故高电平拍数恰好等于 duty（pwm_out 滞后一拍不影响计数）
    task check_duty(input [WIDTH-1:0] d);
        integer hi, k;
        begin
            @(negedge clk); duty = d;
            repeat (3) @(posedge clk);   // 等占空比稳定
            hi = 0;
            for (k = 0; k < PERIOD; k = k + 1) begin
                @(posedge clk); #1;
                if (pwm_out) hi = hi + 1;
            end
            if (hi !== d) begin
                errors = errors + 1;
                $display("[FAIL] duty=%0d: high cycles=%0d exp=%0d", d, hi, d);
            end else
                $display("[ OK ] duty=%0d -> %0d/%0d high", d, hi, PERIOD);
        end
    endtask

    initial begin
        $dumpfile("pwm_tb.vcd");
        $dumpvars(0, pwm_tb);

        duty = 0; rst_n = 0;
        repeat (2) @(posedge clk); rst_n = 1;

        check_duty(4'd0);    // 常低
        check_duty(4'd4);    // 25%
        check_duty(4'd8);    // 50%
        check_duty(4'd12);   // 75%
        check_duty(4'd15);   // ~94%

        if (errors == 0)
            $display("[PASS] pwm: all duty levels correct");
        else begin
            $display("[FAIL] pwm: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
