// 约翰逊（扭环）计数器：把最高位取反后移入最低位，2N 个状态
`timescale 1ns/1ps

module johnson_counter #(
    parameter integer N = 4
) (
    input  wire         clk,
    input  wire         rst_n,
    output reg  [N-1:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= {N{1'b0}};
        else        q <= {q[N-2:0], ~q[N-1]};
    end
endmodule
