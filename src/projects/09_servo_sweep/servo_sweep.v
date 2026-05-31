// 综合项目：舵机自动扫摆 = 位置发生器 + servo_pwm。
// 位置在 0..255 间往复(三角波)，驱动舵机连续扫摆。STEP 控制扫描速度。
`timescale 1ns/1ps

module servo_sweep #(
    parameter integer PERIOD = 2000,
    parameter integer MINP   = 100,
    parameter integer MAXP   = 200,
    parameter integer STEP   = 1
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tick,     // 每个 tick 位置走一步
    output wire       pwm,
    output reg  [7:0] pos
);
    reg dir;     // 1=增 0=减
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin pos <= 0; dir <= 1'b1; end
        else if (tick) begin
            if (dir) begin
                if (pos >= 8'd255 - STEP[7:0]) begin pos <= 8'd255; dir <= 1'b0; end
                else pos <= pos + STEP[7:0];
            end else begin
                if (pos <= STEP[7:0]) begin pos <= 8'd0; dir <= 1'b1; end
                else pos <= pos - STEP[7:0];
            end
        end
    end

    servo_pwm #(.PERIOD(PERIOD), .MINP(MINP), .MAXP(MAXP)) u_servo (
        .clk(clk), .rst_n(rst_n), .pos(pos), .pwm(pwm));
endmodule
