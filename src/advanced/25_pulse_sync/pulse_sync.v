// 跨时钟域脉冲同步器：源域单拍脉冲 -> 电平翻转(toggle) -> 目的域 2 级触发器同步
// -> 边沿检测还原为目的域单拍脉冲。适用于慢->快或快->慢的偶发脉冲传递。
`timescale 1ns/1ps

module pulse_sync (
    input  wire src_clk,
    input  wire src_rst_n,
    input  wire src_pulse,
    input  wire dst_clk,
    input  wire dst_rst_n,
    output wire dst_pulse
);
    reg toggle;          // 源域：每来一个脉冲翻转一次
    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) toggle <= 1'b0;
        else if (src_pulse) toggle <= ~toggle;
    end

    reg s1, s2, s3;      // 目的域 2FF 同步 + 延迟一拍用于边沿检测
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin s1<=1'b0; s2<=1'b0; s3<=1'b0; end
        else begin s1<=toggle; s2<=s1; s3<=s2; end
    end

    assign dst_pulse = s2 ^ s3;   // 同步后电平翻转 -> 输出一拍脉冲
endmodule
