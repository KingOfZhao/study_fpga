// 自校验 testbench：按键消抖 + 计数 + 数码管显示
// 1) 模拟带抖动的按键，校验"一次按下只 +1"
// 2) 校验 count 经 bin2bcd + seg7 后的个/十/百位段码与标准表一致
`timescale 1ns/1ps

module button_counter_seg_tb;
    localparam DB_N = 4;

    reg        clk = 0;
    reg        rst_n;
    reg        btn_in;
    wire [7:0] count;
    wire [7:0] seg_huns, seg_tens, seg_ones;
    integer    errors = 0;
    integer    k;

    button_counter_seg #(.DB_N(DB_N)) dut (
        .clk(clk), .rst_n(rst_n), .btn_in(btn_in),
        .count(count), .seg_huns(seg_huns), .seg_tens(seg_tens), .seg_ones(seg_ones)
    );

    always #5 clk = ~clk;

    // 标准共阳极段码表（与 seg7.v 一致），供校验
    function [7:0] seg_of;
        input [3:0] d;
        begin
            case (d)
                4'd0: seg_of = 8'hC0; 4'd1: seg_of = 8'hF9;
                4'd2: seg_of = 8'hA4; 4'd3: seg_of = 8'hB0;
                4'd4: seg_of = 8'h99; 4'd5: seg_of = 8'h92;
                4'd6: seg_of = 8'h82; 4'd7: seg_of = 8'hF8;
                4'd8: seg_of = 8'h80; 4'd9: seg_of = 8'h90;
                default: seg_of = 8'hFF;
            endcase
        end
    endfunction

    // 模拟一次"带抖动"的按下：先抖动几下，再稳定保持足够久，然后松开（也带抖动）
    task press_once;
        integer j;
        begin
            // 抖动阶段：快速跳变，时间短于去抖窗口，不应被认可
            for (j = 0; j < 3; j = j + 1) begin
                btn_in = 1'b1; @(negedge clk);
                btn_in = 1'b0; @(negedge clk);
            end
            // 稳定按下，保持远超去抖窗口
            btn_in = 1'b1;
            repeat (4 * DB_N + 8) @(negedge clk);
            // 松开并稳定
            btn_in = 1'b0;
            repeat (4 * DB_N + 8) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("button_counter_seg_tb.vcd");
        $dumpvars(0, button_counter_seg_tb);

        btn_in = 1'b0;
        rst_n  = 1'b0;
        repeat (4) @(negedge clk);
        rst_n  = 1'b1;
        repeat (4) @(negedge clk);

        if (count !== 8'd0) begin
            errors = errors + 1;
            $display("[FAIL] 复位后 count 应为 0，实际 %0d", count);
        end

        // 连按 12 次，每次应恰好 +1
        for (k = 1; k <= 12; k = k + 1) begin
            press_once;
            if (count !== k[7:0]) begin
                errors = errors + 1;
                $display("[FAIL] 第 %0d 次按下后 count=%0d（期望 %0d）", k, count, k);
            end
        end

        // 校验显示段码：count=12 → 个位2/十位1/百位0
        if (seg_ones !== seg_of(4'd2)) begin
            errors = errors + 1;
            $display("[FAIL] 个位段码=0x%02h（期望 0x%02h）", seg_ones, seg_of(4'd2));
        end
        if (seg_tens !== seg_of(4'd1)) begin
            errors = errors + 1;
            $display("[FAIL] 十位段码=0x%02h（期望 0x%02h）", seg_tens, seg_of(4'd1));
        end
        if (seg_huns !== seg_of(4'd0)) begin
            errors = errors + 1;
            $display("[FAIL] 百位段码=0x%02h（期望 0x%02h）", seg_huns, seg_of(4'd0));
        end

        if (errors == 0)
            $display("[PASS] button_counter_seg: 12 次按下精确计数，数码管段码正确");
        else
            $display("[FAIL] button_counter_seg: 共 %0d 处错误", errors);
        $finish;
    end

    // 防卡死超时
    initial begin
        #2_000_000;
        $display("[FAIL] 仿真超时");
        $finish;
    end
endmodule
