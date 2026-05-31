// 原子组件：正交（quadrature）编码器解码器
// 旋转编码器输出两路相位差 90° 的方波 A/B。本模块：
//   1) 两级同步消除亚稳态；2) 在 A 的每个边沿产生一个 tick 脉冲；
//   3) 由 A、B 的相位关系判断旋转方向 dir（1=正转）。
`timescale 1ns/1ps

module quad_decoder (
    input  wire clk,
    input  wire rst_n,
    input  wire a,        // 编码器 A 相（异步）
    input  wire b,        // 编码器 B 相（异步）
    output reg  tick,     // 每个 A 边沿一个单周期脉冲（计步）
    output reg  dir       // 方向：1=正转，0=反转
);
    reg a0, a1, b0, b1;   // 两级同步
    reg a_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a0 <= 1'b0; a1 <= 1'b0;
            b0 <= 1'b0; b1 <= 1'b0;
            a_prev <= 1'b0;
            tick <= 1'b0;
            dir  <= 1'b0;
        end else begin
            a0 <= a; a1 <= a0;
            b0 <= b; b1 <= b0;
            tick <= 1'b0;
            if (a1 ^ a_prev) begin   // A 发生跳变（上升或下降沿）
                tick <= 1'b1;
                dir  <= a1 ^ b1;      // A_new ⊕ B 决定方向
            end
            a_prev <= a1;
        end
    end
endmodule
