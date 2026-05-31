`timescale 1ns/1ps
module pwm_capture_tb;
    localparam W = 16;
    reg clk = 0, rst_n, sig;
    wire [W-1:0] width;
    wire valid;
    integer errors = 0;
    reg [W-1:0] result;
    reg got = 0;

    pwm_capture #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .sig(sig), .width(width), .valid(valid));
    always #5 clk = ~clk;

    always @(posedge clk) if (valid && !got) begin got = 1; result = width; end

    // 产生一个高 10 拍的脉冲
    task pulse(input integer high_clks);
        integer i;
        begin
            @(negedge clk); sig = 1;
            for (i = 0; i < high_clks; i = i + 1) @(negedge clk);
            sig = 0;
            repeat (4) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("pwm_capture_tb.vcd");
        $dumpvars(0, pwm_capture_tb);
        rst_n = 0; sig = 0;
        @(negedge clk); rst_n = 1;
        pulse(10);
        wait (got);
        // 同步器延迟 2 拍，测得宽度应≈10（±2）
        if (result < 8 || result > 12) begin
            errors = errors + 1;
            $display("  测得宽度=%0d 期望≈10", result);
        end
        if (errors == 0) $display("[PASS] pwm_capture: 高脉冲宽度测得=%0d（期望≈10）", result);
        else             $display("[FAIL] pwm_capture: %0d 处错误", errors);
        $finish;
    end

    initial begin #100000; $display("[FAIL] pwm_capture: 超时"); $finish; end
endmodule
