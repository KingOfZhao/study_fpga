// 多路按键消抖：对 N 路按键各自独立消抖，输入稳定 STABLE 个时钟后才更新输出
`timescale 1ns/1ps

module debounce_multi #(
    parameter integer N      = 4,
    parameter integer STABLE = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [N-1:0] din,
    output reg  [N-1:0] dout
);
    localparam integer CW = $clog2(STABLE);
    localparam [CW-1:0] LIM = STABLE[CW-1:0] - 1'b1;

    // 每路一个同步器 + 计数器
    reg [N-1:0]  s1, s2;
    reg [CW-1:0] cnt [0:N-1];

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1 <= 0; s2 <= 0; dout <= 0;
            for (i = 0; i < N; i = i + 1) cnt[i] <= 0;
        end else begin
            s1 <= din; s2 <= s1;
            for (i = 0; i < N; i = i + 1) begin
                if (s2[i] == dout[i]) begin
                    cnt[i] <= 0;                  // 与输出一致，无需变化
                end else if (cnt[i] == LIM) begin
                    dout[i] <= s2[i];             // 稳定足够久，接受新值
                    cnt[i]  <= 0;
                end else begin
                    cnt[i] <= cnt[i] + 1'b1;      // 累计稳定时间
                end
            end
        end
    end
endmodule
