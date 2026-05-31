// PWM 发生器（脉宽调制）—— 常用于 LED 调光、电机调速
// 周期 = 2^WIDTH 个时钟；占空比 = duty / 2^WIDTH。
`timescale 1ns/1ps

module pwm #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] duty,     // 占空比阈值
    output reg              pwm_out
);
    reg [WIDTH-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt     <= {WIDTH{1'b0}};
            pwm_out <= 1'b0;
        end else begin
            cnt     <= cnt + 1'b1;          // 自由运行计数器，自动回绕
            pwm_out <= (cnt < duty);        // 计数小于阈值时输出高
        end
    end
endmodule
