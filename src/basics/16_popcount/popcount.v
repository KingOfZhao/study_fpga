// 人口计数（popcount）：统计输入中 1 的个数（组合，循环累加）
`timescale 1ns/1ps

module popcount #(
    parameter integer W = 8
) (
    input  wire [W-1:0]            din,
    output reg  [$clog2(W+1)-1:0]  count
);
    localparam integer CW = $clog2(W+1);
    integer i;
    always @(*) begin
        count = 0;
        for (i = 0; i < W; i = i + 1)
            count = count + {{(CW-1){1'b0}}, din[i]};
    end
endmodule
