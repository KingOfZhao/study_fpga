// 多通道 PWM：共享一个计数器，每通道独立占空比阈值，输出 N 路 PWM。
`timescale 1ns/1ps

module pwm_multi #(
    parameter integer N = 4,
    parameter integer W = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [N*W-1:0]   duty,    // N 个通道阈值打包
    output reg  [N-1:0]     pwm
);
    reg [W-1:0] cnt;
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; pwm <= 0;
        end else begin
            cnt <= cnt + 1'b1;
            for (i = 0; i < N; i = i + 1)
                pwm[i] <= (cnt < duty[i*W +: W]);   // 计数 < 阈值时输出高
        end
    end
endmodule
