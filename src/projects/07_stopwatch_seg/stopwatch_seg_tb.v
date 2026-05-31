`timescale 1ns/1ps
module stopwatch_seg_tb;
    reg clk = 0, rst_n, run, clr, tick;
    wire [7:0] seg_so, seg_st, seg_mo, seg_mt;
    integer errors = 0, i;

    stopwatch_seg dut (.clk(clk), .rst_n(rst_n), .run(run), .clr(clr), .tick(tick),
        .seg_so(seg_so), .seg_st(seg_st), .seg_mo(seg_mo), .seg_mt(seg_mt));
    always #5 clk = ~clk;

    function integer seg2dig(input [7:0] s);
        begin case (s)
            8'hC0: seg2dig=0; 8'hF9: seg2dig=1; 8'hA4: seg2dig=2; 8'hB0: seg2dig=3;
            8'h99: seg2dig=4; 8'h92: seg2dig=5; 8'h82: seg2dig=6; 8'hF8: seg2dig=7;
            8'h80: seg2dig=8; 8'h90: seg2dig=9; default: seg2dig=-1;
        endcase end
    endfunction

    task one_tick; begin @(negedge clk); tick=1; @(negedge clk); tick=0; repeat(2) @(negedge clk); end endtask

    integer total;
    initial begin
        $dumpfile("stopwatch_seg_tb.vcd");
        $dumpvars(0, stopwatch_seg_tb);
        rst_n=0; run=0; clr=1; tick=0;
        repeat (2) @(negedge clk); rst_n=1; @(negedge clk); clr=0; run=1;
        // 75 个 tick = 1 分 15 秒
        for (i = 0; i < 75; i = i + 1) one_tick;
        #1;
        total = seg2dig(seg_mt)*600 + seg2dig(seg_mo)*60 + seg2dig(seg_st)*10 + seg2dig(seg_so);
        if (total !== 75) begin
            errors=errors+1;
            $display("  显示 %0d%0d:%0d%0d 总秒=%0d 期望=75",
                seg2dig(seg_mt),seg2dig(seg_mo),seg2dig(seg_st),seg2dig(seg_so), total);
        end else
            $display("  计时显示 %0d%0d:%0d%0d (75s)",
                seg2dig(seg_mt),seg2dig(seg_mo),seg2dig(seg_st),seg2dig(seg_so));
        if (errors==0) $display("[PASS] stopwatch_seg: 75 个 tick 后数码管正确显示 01:15");
        else            $display("[FAIL] stopwatch_seg: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] stopwatch_seg: 超时"); $finish; end
endmodule
