// 综合项目：RGB LED 三路 PWM 调光 = pwm x3。
// 三个独立占空比阈值分别驱动 R/G/B，组合出任意颜色/亮度。
`timescale 1ns/1ps

module pwm_rgb #(
    parameter integer W = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [W-1:0] r_duty,
    input  wire [W-1:0] g_duty,
    input  wire [W-1:0] b_duty,
    output wire         r,
    output wire         g,
    output wire         b
);
    pwm #(.WIDTH(W)) u_r (.clk(clk), .rst_n(rst_n), .duty(r_duty), .pwm_out(r));
    pwm #(.WIDTH(W)) u_g (.clk(clk), .rst_n(rst_n), .duty(g_duty), .pwm_out(g));
    pwm #(.WIDTH(W)) u_b (.clk(clk), .rst_n(rst_n), .duty(b_duty), .pwm_out(b));
endmodule
