// 轮询(Round-Robin)仲裁器：N 路请求，每次授权一个，优先级在被授权者之后轮转，保证公平。
`timescale 1ns/1ps

module rr_arbiter #(
    parameter integer N = 4
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [N-1:0] req,
    output wire [N-1:0] grant
);
    reg [N-1:0] mask;        // 当前轮转优先掩码：从上次授权之后开始

    // 在 mask 范围内(>= 指针)找最低置位；否则回绕找全局最低置位
    wire [N-1:0] req_hi   = req & mask;
    wire [N-1:0] grant_hi = req_hi & (~req_hi + {{(N-1){1'b0}}, 1'b1});
    wire [N-1:0] grant_lo = req     & (~req    + {{(N-1){1'b0}}, 1'b1});
    assign grant = (req_hi != 0) ? grant_hi : grant_lo;

    integer k, j;
    integer g;
    reg [N-1:0] next_mask;
    always @(*) begin
        g = 0;
        for (k = 0; k < N; k = k + 1) if (grant[k]) g = k;
        for (j = 0; j < N; j = j + 1) next_mask[j] = (j > g);
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) mask <= {N{1'b1}};
        else if (|grant) mask <= next_mask;
    end
endmodule
