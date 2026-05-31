// clk_divider 自校验 testbench —— 验证 tick 间隔恰好为 DIV 个时钟
`timescale 1ns/1ps

module clk_divider_tb;
    localparam DIV = 5;

    reg  clk = 1'b0;
    reg  rst_n;
    wire tick;

    integer last_tick = -1;     // 上一次 tick 发生的周期号
    integer cyc       = 0;      // 时钟周期计数
    integer ticks     = 0;      // 已观测到的 tick 数
    integer errors    = 0;

    clk_divider #(.DIV(DIV)) dut (.clk(clk), .rst_n(rst_n), .tick(tick));

    always #5 clk = ~clk;       // 100MHz 等效

    // 在每个上升沿统计：若出现 tick，检查与上一次的间隔
    always @(posedge clk) begin
        if (rst_n) begin
            cyc = cyc + 1;
            if (tick) begin
                ticks = ticks + 1;
                if (last_tick >= 0) begin
                    if ((cyc - last_tick) !== DIV) begin
                        errors = errors + 1;
                        $display("[FAIL] tick 间隔=%0d 期望=%0d", cyc - last_tick, DIV);
                    end else
                        $display("[ OK ] 第 %0d 次 tick，间隔=%0d", ticks, cyc - last_tick);
                end
                last_tick = cyc;
            end
        end
    end

    initial begin
        $dumpfile("clk_divider_tb.vcd");
        $dumpvars(0, clk_divider_tb);
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        // 跑足够多周期，观测多次 tick
        repeat (DIV * 6 + 5) @(posedge clk);

        if (ticks < 4) begin
            errors = errors + 1;
            $display("[FAIL] 观测到的 tick 太少：%0d", ticks);
        end

        if (errors == 0)
            $display("[PASS] clk_divider: tick 间隔恒为 %0d，共 %0d 次", DIV, ticks);
        else begin
            $display("[FAIL] clk_divider: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
