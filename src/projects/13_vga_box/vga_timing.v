// VGA 时序产生器（默认 640×480@60Hz，像素时钟 25MHz）
// 产生 hsync/vsync 同步脉冲、可见区标志 active 以及当前像素坐标 px/py。
// 全部参数化：改参数即可换分辨率。同步脉冲为负极性（低有效，VGA 标准）。
`timescale 1ns/1ps

module vga_timing #(
    parameter H_VISIBLE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48,
    parameter V_VISIBLE = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33
) (
    input  wire       clk,        // 像素时钟
    input  wire       rst_n,
    output reg        hsync,      // 行同步（低有效）
    output reg        vsync,      // 场同步（低有效）
    output reg        active,     // 处于可见区
    output reg [9:0]  px,         // 可见区内的列坐标
    output reg [9:0]  py          // 可见区内的行坐标
);
    localparam H_TOTAL = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;  // 默认 800
    localparam V_TOTAL = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;  // 默认 525

    reg [9:0] hcnt, vcnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hcnt <= 10'd0;
            vcnt <= 10'd0;
        end else if (hcnt == (H_TOTAL - 1)) begin
            hcnt <= 10'd0;
            vcnt <= (vcnt == (V_TOTAL - 1)) ? 10'd0 : (vcnt + 1'b1);
        end else begin
            hcnt <= hcnt + 1'b1;
        end
    end

    always @(*) begin
        // 同步脉冲出现在"可见区 + 前肩"之后的 SYNC 段，低有效
        hsync  = ~((hcnt >= (H_VISIBLE + H_FRONT)) && (hcnt < (H_VISIBLE + H_FRONT + H_SYNC)));
        vsync  = ~((vcnt >= (V_VISIBLE + V_FRONT)) && (vcnt < (V_VISIBLE + V_FRONT + V_SYNC)));
        active = (hcnt < H_VISIBLE) && (vcnt < V_VISIBLE);
        px     = active ? hcnt : 10'd0;
        py     = active ? vcnt : 10'd0;
    end
endmodule
