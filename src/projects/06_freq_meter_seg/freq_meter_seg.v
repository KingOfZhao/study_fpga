// 综合项目：频率计 + 数码管显示 = freq_counter + bin2bcd + seg7 x3。
// 闸门窗口测得输入信号边沿数，转 BCD 后在三位数码管上显示(百/十/个)。
`timescale 1ns/1ps

module freq_meter_seg #(
    parameter integer GATE = 200,
    parameter integer W    = 16
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sig,
    output wire [W-1:0] freq,
    output wire        done,
    output wire [7:0]  seg_h,
    output wire [7:0]  seg_t,
    output wire [7:0]  seg_o
);
    wire [3:0] huns, tens, ones;

    freq_counter #(.GATE(GATE), .W(W)) u_fc (
        .clk(clk), .rst_n(rst_n), .sig(sig), .freq(freq), .done(done));

    bin2bcd u_b2b (.bin(freq[7:0]), .huns(huns), .tens(tens), .ones(ones));

    seg7 u_sh (.digit(huns), .seg(seg_h));
    seg7 u_st (.digit(tens), .seg(seg_t));
    seg7 u_so (.digit(ones), .seg(seg_o));
endmodule
