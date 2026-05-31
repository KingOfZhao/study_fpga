// 组合案例 01：旋转编码器 + 测速 + 比例控制 + PWM —— 闭环电机调速
// 真实工程里最常见的"闭环控制"骨架：
//   编码器测实际转速 → 与目标比较 → 控制器调占空比 → PWM 驱动电机 → 转速改变 → 再测…
//
//   enc_a/enc_b ─▶[quad_decoder]─tick─▶[speed_meter]─speed─▶[p_controller]─duty─▶[pwm]─▶ pwm_out
//                                                          ▲ target                         │
//                                                          └──────────── 反馈闭环 ───────────┘
`timescale 1ns/1ps

module motor_speed_ctrl #(
    parameter integer DW   = 8,    // 占空比/目标位宽
    parameter integer SPDW = 9,    // 速度位宽
    parameter integer WIN  = 512,  // 测速窗口（时钟数）
    parameter integer KSH  = 2     // 控制器增益
) (
    input  wire            clk,
    input  wire            rst_n,
    input  wire            enc_a,    // 编码器 A 相
    input  wire            enc_b,    // 编码器 B 相
    input  wire [DW-1:0]   target,   // 目标转速
    output wire [DW-1:0]   duty,     // 当前占空比
    output wire [SPDW-1:0] speed,    // 实测转速
    output wire            dir,      // 旋转方向
    output wire            sample,   // 测速窗口脉冲
    output wire            pwm_out   // PWM 输出（驱动 H 桥/MOSFET）
);
    wire tick;

    quad_decoder u_qd (
        .clk(clk), .rst_n(rst_n),
        .a(enc_a), .b(enc_b),
        .tick(tick), .dir(dir)
    );

    speed_meter #(.WIN(WIN), .SPDW(SPDW)) u_sm (
        .clk(clk), .rst_n(rst_n),
        .tick(tick), .speed(speed), .sample(sample)
    );

    p_controller #(.DW(DW), .SPDW(SPDW), .KSH(KSH)) u_pc (
        .clk(clk), .rst_n(rst_n),
        .sample(sample), .speed(speed), .target(target), .duty(duty)
    );

    pwm #(.WIDTH(DW)) u_pwm (
        .clk(clk), .rst_n(rst_n),
        .duty(duty), .pwm_out(pwm_out)
    );
endmodule
