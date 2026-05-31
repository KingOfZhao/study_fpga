`timescale 1ns/1ps
module pwm_multi_tb;
    localparam N = 4, W = 8;
    reg clk = 0, rst_n;
    reg  [N*W-1:0] duty;
    wire [N-1:0]   pwm;
    integer errors = 0;
    integer high [0:N-1];
    integer i, k, ev;
    reg [W-1:0] dval [0:N-1];

    pwm_multi #(.N(N), .W(W)) dut (.clk(clk), .rst_n(rst_n), .duty(duty), .pwm(pwm));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("pwm_multi_tb.vcd");
        $dumpvars(0, pwm_multi_tb);
        rst_n = 0;
        dval[0]=8'd0; dval[1]=8'd64; dval[2]=8'd128; dval[3]=8'd255;
        duty = {dval[3], dval[2], dval[1], dval[0]};
        for (i = 0; i < N; i = i + 1) high[i] = 0;
        @(negedge clk); rst_n = 1;
        // 让 cnt 从 0 对齐：等其回到 0 附近后统计一个完整周期(256 拍)
        @(negedge clk);
        for (k = 0; k < 256; k = k + 1) begin
            @(negedge clk);
            for (i = 0; i < N; i = i + 1) if (pwm[i]) high[i] = high[i] + 1;
        end
        for (i = 0; i < N; i = i + 1) begin
            ev = dval[i];   // 转为有符号 integer 再比较
            if (high[i] < ev-2 || high[i] > ev+2) begin
                errors = errors + 1;
                $display("  通道%0d 高=%0d 期望≈%0d", i, high[i], ev);
            end else
                $display("  通道%0d 高=%0d / 256 (阈值%0d)", i, high[i], ev);
        end
        if (errors == 0) $display("[PASS] pwm_multi: 4 通道占空比与阈值一致");
        else             $display("[FAIL] pwm_multi: %0d 处错误", errors);
        $finish;
    end
endmodule
