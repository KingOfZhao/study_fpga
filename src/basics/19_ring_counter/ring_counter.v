// 环形计数器：单个 1 在 N 位里循环移动（复位后为 ...0001）
`timescale 1ns/1ps

module ring_counter #(
    parameter integer N = 4
) (
    input  wire         clk,
    input  wire         rst_n,
    output reg  [N-1:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= {{(N-1){1'b0}}, 1'b1};
        else        q <= {q[N-2:0], q[N-1]};   // 循环左移
    end
endmodule
