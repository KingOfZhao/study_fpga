`timescale 1ns/1ps
module servo_sweep_tb;
    localparam PERIOD = 2000, MINP = 100, MAXP = 200, STEP = 1;
    reg clk = 0, rst_n, tick;
    wire pwm;
    wire [7:0] pos;
    integer errors = 0, k;
    integer high, expw;
    integer maxpos, turned;
    reg [7:0] prevpos;

    servo_sweep #(.PERIOD(PERIOD), .MINP(MINP), .MAXP(MAXP), .STEP(STEP)) dut (
        .clk(clk), .rst_n(rst_n), .tick(tick), .pwm(pwm), .pos(pos));
    always #5 clk = ~clk;

    task ticks(input integer n);
        integer t;
        begin
            for (t = 0; t < n; t = t + 1) begin
                @(negedge clk); tick=1; @(negedge clk); tick=0;
            end
        end
    endtask

    task meas_high;
        begin
            @(negedge clk); high=0;
            for (k = 0; k < PERIOD; k = k + 1) begin @(negedge clk); if (pwm) high=high+1; end
        end
    endtask

    initial begin
        $dumpfile("servo_sweep_tb.vcd");
        $dumpvars(0, servo_sweep_tb);
        rst_n=0; tick=0;
        repeat (2) @(negedge clk); rst_n=1;
        // 走 50 步 -> pos=50
        ticks(50);
        if (pos !== 8'd50) begin errors=errors+1; $display("  50 步后 pos=%0d 期望=50", pos); end
        tick=0; meas_high;
        expw = MINP + (50*(MAXP-MINP))/255;
        if (high < expw-2 || high > expw+2) begin errors=errors+1; $display("  pos=50 高=%0d 期望≈%0d", high, expw); end
        else $display("  pos=50 脉宽=%0d 拍 (期望≈%0d)", high, expw);

        // 继续扫描验证三角波折返
        maxpos=0; turned=0; prevpos=pos;
        for (k = 0; k < 500; k = k + 1) begin
            ticks(1);
            if (pos > maxpos[7:0]) maxpos = pos;
            if (pos < prevpos) turned = 1;   // 出现下降 => 已折返
            prevpos = pos;
        end
        if (maxpos < 255) begin errors=errors+1; $display("  未到达最大 255 (max=%0d)", maxpos); end
        if (!turned)      begin errors=errors+1; $display("  未观察到折返(三角波)"); end

        if (errors==0) $display("[PASS] servo_sweep: 位置三角波扫摆且舵机脉宽随 pos 线性正确");
        else            $display("[FAIL] servo_sweep: %0d 处错误", errors);
        $finish;
    end
    initial begin #5000000; $display("[FAIL] servo_sweep: 超时"); $finish; end
endmodule
