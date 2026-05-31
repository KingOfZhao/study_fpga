// 原子组件：比例（积分式）控制器
// 每来一个 sample，按误差调整占空比：duty += (target - speed) >> KSH，并钳位到 [0,255]。
// 这是"积分作用"——只要还有误差就持续累加 duty，最终把误差逼到 0（闭环稳态）。
`timescale 1ns/1ps

module p_controller #(
    parameter integer DW   = 8,   // 占空比位宽
    parameter integer SPDW = 9,   // 速度位宽
    parameter integer KSH  = 2    // 增益：误差右移位数（越大越慢越稳）
) (
    input  wire            clk,
    input  wire            rst_n,
    input  wire            sample,        // 新的测速结果有效
    input  wire [SPDW-1:0] speed,         // 实测转速
    input  wire [DW-1:0]   target,        // 目标转速
    output reg  [DW-1:0]   duty           // 输出占空比
);
    // 统一在 16 位有符号域里运算，避免下溢/上溢
    wire signed [15:0] target_s = $signed({{(16-DW){1'b0}},   target});
    wire signed [15:0] speed_s  = $signed({{(16-SPDW){1'b0}}, speed});
    wire signed [15:0] duty_s   = $signed({{(16-DW){1'b0}},   duty});

    wire signed [15:0] err      = target_s - speed_s;
    wire signed [15:0] step     = err >>> KSH;          // 比例增量（算术右移）
    wire signed [15:0] nxt      = duty_s + step;

    // 钳位到 [0, 2^DW-1]
    localparam signed [15:0] DUTY_MAX = (1 << DW) - 1;
    wire signed [15:0] clamped = (nxt < 16'sd0)   ? 16'sd0   :
                                 (nxt > DUTY_MAX) ? DUTY_MAX : nxt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            duty <= {DW{1'b0}};
        else if (sample)
            duty <= clamped[DW-1:0];
    end
endmodule
