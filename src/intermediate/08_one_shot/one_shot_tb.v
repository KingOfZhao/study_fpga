`timescale 1ns/1ps
module one_shot_tb;
    localparam N = 8;
    reg clk = 0, rst_n, trig;
    wire pulse;
    integer errors = 0;
    integer width;

    one_shot #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .trig(trig), .pulse(pulse));
    always #5 clk = ~clk;

    // 测量 pulse 高电平持续的时钟数
    always @(posedge clk) if (pulse) width = width + 1;

    initial begin
        $dumpfile("one_shot_tb.vcd");
        $dumpvars(0, one_shot_tb);
        rst_n = 0; trig = 0; width = 0;
        @(negedge clk); rst_n = 1;
        @(negedge clk); trig = 1;          // 触发（保持高，验证不重复触发）
        repeat (20) @(negedge clk);
        trig = 0;
        repeat (5) @(negedge clk);
        if (width != N) begin
            errors = errors + 1;
            $display("  脉宽=%0d 期望=%0d", width, N);
        end
        if (errors == 0) $display("[PASS] one_shot: 单次触发输出 %0d 个时钟宽脉冲", N);
        else             $display("[FAIL] one_shot: %0d 处错误", errors);
        $finish;
    end
endmodule
