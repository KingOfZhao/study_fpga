// 分频器 / 节拍发生器（时序逻辑）
// 每 DIV 个输入时钟，产生一个持续 1 个周期的 tick 脉冲。
// 是"用快时钟造慢节拍"的标准手法（按键扫描、刷新、波特率分频都靠它）。
`timescale 1ns/1ps

module clk_divider #(
    parameter DIV = 4          // 分频比（>=1）
) (
    input  wire clk,
    input  wire rst_n,         // 低电平有效复位
    output reg  tick           // 每 DIV 个时钟高 1 拍
);
    // 计数器位宽：刚好放下 0..DIV-1
    localparam integer    CW   = (DIV <= 2) ? 1 : $clog2(DIV);
    localparam [CW-1:0] LAST = (CW)'(DIV - 1);

    reg [CW-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt  <= {CW{1'b0}};
            tick <= 1'b0;
        end else if (cnt == LAST) begin
            cnt  <= {CW{1'b0}};
            tick <= 1'b1;
        end else begin
            cnt  <= cnt + 1'b1;
            tick <= 1'b0;
        end
    end
endmodule
