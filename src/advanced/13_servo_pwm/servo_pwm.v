// RC 舵机 PWM：固定周期 PERIOD 拍，高电平宽度 = MIN + pos*(MAX-MIN)/255。
// 真实舵机：周期 20ms，高 1~2ms。这里参数化以便仿真。
`timescale 1ns/1ps

module servo_pwm #(
    parameter integer PERIOD = 2000,   // 一个周期的时钟数
    parameter integer MINP   = 100,    // pos=0   的高电平拍数
    parameter integer MAXP   = 200     // pos=255 的高电平拍数
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  pos,
    output reg         pwm
);
    localparam integer PW = $clog2(PERIOD);
    reg [PW-1:0] cnt;
    // 高电平宽度 = MINP + pos*(MAXP-MINP)/255
    wire [31:0] span  = (MAXP - MINP);
    wire [31:0] hi    = MINP + (pos * span) / 255;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; pwm <= 0;
        end else begin
            if (cnt == PERIOD[PW-1:0] - 1'b1) cnt <= 0;
            else cnt <= cnt + 1'b1;
            pwm <= ({{(32-PW){1'b0}}, cnt} < hi);
        end
    end
endmodule
