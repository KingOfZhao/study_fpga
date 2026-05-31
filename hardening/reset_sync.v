// 复位同步器（异步置位 / 同步释放）：复位立即生效，释放时与时钟对齐，
// 避免复位释放瞬间各触发器不同步导致的非法状态。上板推荐替换裸 negedge rst_n。
`timescale 1ns/1ps
module reset_sync #(
    parameter STAGES = 2
)(
    input  wire clk,
    input  wire arst_n,     // 异步复位输入（低有效）
    output wire srst_n      // 同步释放后的复位（低有效）
);
    reg [STAGES-1:0] q;
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) q <= {STAGES{1'b0}};
        else         q <= {q[STAGES-2:0], 1'b1};
    end
    assign srst_n = q[STAGES-1];
endmodule
