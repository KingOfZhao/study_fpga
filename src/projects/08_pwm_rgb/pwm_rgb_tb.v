`timescale 1ns/1ps
module pwm_rgb_tb;
    localparam W = 8, PERIOD = 256;
    reg clk = 0, rst_n;
    reg  [W-1:0] r_duty, g_duty, b_duty;
    wire r, g, b;
    integer errors = 0, k;
    integer hr, hg, hb;

    pwm_rgb #(.W(W)) dut (.clk(clk), .rst_n(rst_n),
        .r_duty(r_duty), .g_duty(g_duty), .b_duty(b_duty), .r(r), .g(g), .b(b));
    always #5 clk = ~clk;

    task measure(input [W-1:0] rd, input [W-1:0] gd, input [W-1:0] bd);
        begin
            r_duty=rd; g_duty=gd; b_duty=bd;
            // 对齐到周期起点
            @(negedge clk); hr=0; hg=0; hb=0;
            for (k = 0; k < PERIOD; k = k + 1) begin
                @(negedge clk);
                if (r) hr=hr+1; if (g) hg=hg+1; if (b) hb=hb+1;
            end
            if (hr<rd-2 || hr>rd+2) begin errors=errors+1; $display("  R 高=%0d 期望≈%0d", hr, rd); end
            if (hg<gd-2 || hg>gd+2) begin errors=errors+1; $display("  G 高=%0d 期望≈%0d", hg, gd); end
            if (hb<bd-2 || hb>bd+2) begin errors=errors+1; $display("  B 高=%0d 期望≈%0d", hb, bd); end
            $display("  duty(%0d,%0d,%0d) -> 高(%0d,%0d,%0d)/256", rd,gd,bd, hr,hg,hb);
        end
    endtask

    initial begin
        $dumpfile("pwm_rgb_tb.vcd");
        $dumpvars(0, pwm_rgb_tb);
        rst_n=0; r_duty=0; g_duty=0; b_duty=0;
        repeat (2) @(negedge clk); rst_n=1;
        measure(8'd64, 8'd128, 8'd192);
        measure(8'd200, 8'd50, 8'd255);
        if (errors==0) $display("[PASS] pwm_rgb: 三路独立 PWM 占空比与阈值一致");
        else            $display("[FAIL] pwm_rgb: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] pwm_rgb: 超时"); $finish; end
endmodule
