// DDS / NCO 直接数字频率合成：相位累加器 + 正弦查找表。
// 每个时钟相位累加 fword，取相位高位查表输出正弦样本，fword 决定输出频率。
`timescale 1ns/1ps

module dds #(
    parameter integer PA = 12,    // 相位累加器位宽
    parameter integer AW = 6,     // 查找表地址位宽（表深 2^AW）
    parameter integer DW = 8      // 样本位宽
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          en,
    input  wire [PA-1:0] fword,
    output reg  [DW-1:0] wave
);
    reg [DW-1:0] rom [0:(1<<AW)-1];
    reg [PA-1:0] phase;
    integer i, v;
    real     s;
    localparam real PI = 3.14159265358979;

    initial begin
        for (i = 0; i < (1<<AW); i = i + 1) begin
            s = $sin(2.0 * PI * i / (1<<AW));
            v = $rtoi((s + 1.0) * ((1 << DW) - 1) / 2.0 + 0.5);
            rom[i] = v[DW-1:0];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) phase <= 0;
        else if (en) phase <= phase + fword;
    end

    always @(*) wave = rom[phase[PA-1:PA-AW]];
endmodule
