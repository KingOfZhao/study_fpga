// 乘累加器 MAC：每个 valid 拍 acc += a*b；clr 清零。DSP 滤波/卷积的核心运算单元。
`timescale 1ns/1ps

module mac #(
    parameter integer W   = 8,
    parameter integer ACC = 32
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 clr,
    input  wire                 valid,
    input  wire signed [W-1:0]  a,
    input  wire signed [W-1:0]  b,
    output reg  signed [ACC-1:0] acc
);
    wire signed [2*W-1:0] prod = a * b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      acc <= 0;
        else if (clr)    acc <= 0;
        else if (valid)  acc <= acc + {{(ACC-2*W){prod[2*W-1]}}, prod};
    end
endmodule
