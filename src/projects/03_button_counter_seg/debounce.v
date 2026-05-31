// 按键消抖 + 边沿检测
// 机械按键按下/松开时会"抖动"（几毫秒内反复跳变）。
// 做法：先两级同步进时钟域，再要求电平连续稳定 N 个采样才认可，
// 并在认可的瞬间输出单周期的上升沿/下降沿脉冲。
`timescale 1ns/1ps

module debounce #(
    parameter N = 4            // 需要稳定的采样次数
) (
    input  wire clk,
    input  wire rst_n,
    input  wire btn_in,        // 带抖动的原始输入（异步）
    output reg  btn_state,     // 去抖后的稳定电平
    output reg  btn_rise,      // 按下瞬间（上升沿）单周期脉冲
    output reg  btn_fall       // 松开瞬间（下降沿）单周期脉冲
);
    localparam integer  CW   = (N <= 2) ? 1 : $clog2(N);
    localparam [CW-1:0] LAST = (CW)'(N - 1);

    reg          sync0, sync1; // 两级同步，消除亚稳态
    reg [CW-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0     <= 1'b0;
            sync1     <= 1'b0;
            cnt       <= {CW{1'b0}};
            btn_state <= 1'b0;
            btn_rise  <= 1'b0;
            btn_fall  <= 1'b0;
        end else begin
            sync0    <= btn_in;
            sync1    <= sync0;
            btn_rise <= 1'b0;
            btn_fall <= 1'b0;

            if (sync1 == btn_state) begin
                cnt <= {CW{1'b0}};          // 与当前稳定值一致，清零计数
            end else if (cnt == LAST) begin
                btn_state <= sync1;         // 连续稳定够久，认可新电平
                cnt       <= {CW{1'b0}};
                btn_rise  <=  sync1 & ~btn_state;
                btn_fall  <= ~sync1 &  btn_state;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end
endmodule
