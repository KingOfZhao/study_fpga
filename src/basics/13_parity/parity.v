// 奇偶校验：even_par = 数据中 1 的个数的异或（偶校验位）；odd_par 取反
`timescale 1ns/1ps

module parity #(
    parameter integer W = 8
) (
    input  wire [W-1:0] data,
    output wire         even_par,   // 使总 1 个数为偶时需附加的位
    output wire         odd_par
);
    assign even_par = ^data;     // 1 的个数为奇 -> 1
    assign odd_par  = ~(^data);
endmodule
