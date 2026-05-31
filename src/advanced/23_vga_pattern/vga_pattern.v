// VGA 彩条图案发生器（组合）：按像素 x 坐标分成 8 条标准彩条，de 无效时输出黑。
// 与 advanced/03 的时序发生器配合即可在屏上显示彩条。
`timescale 1ns/1ps

module vga_pattern #(
    parameter integer HACT = 640,
    parameter integer BARS = 8,
    parameter integer CW   = 4     // 每通道色深
) (
    input  wire [9:0]    x,
    input  wire          de,       // 显示有效
    output reg  [CW-1:0] r,
    output reg  [CW-1:0] g,
    output reg  [CW-1:0] b
);
    localparam integer    BARW  = HACT / BARS;   // 每条宽度(=80)
    localparam [9:0]      BARW10 = BARW[9:0];
    reg [9:0] qbar;
    always @(*) begin
        if (!de) begin
            r = 0; g = 0; b = 0;
        end else begin
            qbar = x / BARW10;
            if (qbar > 10'd7) qbar = 10'd7;
            r = qbar[2] ? {CW{1'b1}} : {CW{1'b0}};
            g = qbar[1] ? {CW{1'b1}} : {CW{1'b0}};
            b = qbar[0] ? {CW{1'b1}} : {CW{1'b0}};
        end
    end
endmodule
