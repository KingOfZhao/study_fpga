// 通用移位寄存器：支持 并行装载 / 左移(串入) / 右移(串入) / 保持
// mode: 00 保持, 01 右移(从高位串入 sin_r), 10 左移(从低位串入 sin_l), 11 并行装载 din
`timescale 1ns/1ps

module shift_register #(
    parameter integer W = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [1:0]   mode,
    input  wire         sin_l,   // 左移时移入最低位
    input  wire         sin_r,   // 右移时移入最高位
    input  wire [W-1:0] din,
    output reg  [W-1:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= {W{1'b0}};
        else case (mode)
            2'b00: q <= q;
            2'b01: q <= {sin_r, q[W-1:1]};   // 右移
            2'b10: q <= {q[W-2:0], sin_l};   // 左移
            default: q <= din;               // 并行装载
        endcase
    end
endmodule
