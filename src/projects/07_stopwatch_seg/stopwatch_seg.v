// 综合项目：秒表 + 数码管 = stopwatch + seg7 x4。
// 计时 mm:ss 的四位 BCD 经数码管译码输出。
`timescale 1ns/1ps

module stopwatch_seg (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       run,
    input  wire       clr,
    input  wire       tick,
    output wire [7:0] seg_so,   // 秒个位
    output wire [7:0] seg_st,   // 秒十位
    output wire [7:0] seg_mo,   // 分个位
    output wire [7:0] seg_mt    // 分十位
);
    wire [3:0] so, st, mo, mt;

    stopwatch u_sw (
        .clk(clk), .rst_n(rst_n), .run(run), .clr(clr), .tick(tick),
        .sec_ones(so), .sec_tens(st), .min_ones(mo), .min_tens(mt));

    seg7 u0 (.digit(so), .seg(seg_so));
    seg7 u1 (.digit(st), .seg(seg_st));
    seg7 u2 (.digit(mo), .seg(seg_mo));
    seg7 u3 (.digit(mt), .seg(seg_mt));
endmodule
