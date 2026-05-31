`timescale 1ns/1ps
module duty_measure_tb;
    localparam W = 16;
    reg clk = 0, rst_n, sig;
    wire [7:0] duty;
    wire [W-1:0] period;
    wire valid;
    integer errors = 0;
    reg [7:0] result;
    reg got = 0;

    duty_measure #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .sig(sig),
                               .duty(duty), .period(period), .valid(valid));
    always #5 clk = ~clk;

    // 输入信号：周期 20 个时钟，高 15 低 5 -> 占空比 75%
    integer p = 0;
    always @(posedge clk) begin
        p = p + 1;
        sig = (p % 20) < 15;
    end

    // 跳过第一个测量(可能未对齐)，取第二个稳定值
    integer cnt = 0;
    always @(posedge clk) if (valid) begin
        cnt = cnt + 1;
        if (cnt == 2) begin got = 1; result = duty; end
    end

    initial begin
        $dumpfile("duty_measure_tb.vcd");
        $dumpvars(0, duty_measure_tb);
        rst_n = 0; sig = 0;
        @(negedge clk); rst_n = 1;
        wait (got);
        if (result < 73 || result > 77) begin
            errors = errors + 1;
            $display("  测得占空比=%0d%% 期望≈75%%", result);
        end
        if (errors == 0) $display("[PASS] duty_measure: 测得占空比=%0d%%（期望≈75%%）", result);
        else             $display("[FAIL] duty_measure: %0d 处错误", errors);
        $finish;
    end

    initial begin #100000; $display("[FAIL] duty_measure: 超时"); $finish; end
endmodule
