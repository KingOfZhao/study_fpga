// 单稳态/脉冲展宽：输入 trig 上升沿触发，输出 pulse 持续 N 个时钟后自动结束
`timescale 1ns/1ps

module one_shot #(
    parameter integer N = 8
) (
    input  wire clk,
    input  wire rst_n,
    input  wire trig,
    output reg  pulse
);
    localparam integer CW = $clog2(N+1);
    reg                 trig_d;
    reg [CW-1:0]        cnt;

    wire trig_rise = trig & ~trig_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trig_d <= 1'b0; cnt <= 0; pulse <= 1'b0;
        end else begin
            trig_d <= trig;
            if (trig_rise) begin
                pulse <= 1'b1;
                cnt   <= N[CW-1:0];
            end else if (cnt != 0) begin
                cnt <= cnt - 1'b1;
                if (cnt == 1) pulse <= 1'b0;
            end
        end
    end
endmodule
