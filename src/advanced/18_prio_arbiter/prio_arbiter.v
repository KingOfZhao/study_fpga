// 固定优先级仲裁器（组合）：最低索引优先，输出单热 grant 与 valid。
`timescale 1ns/1ps

module prio_arbiter #(
    parameter integer N = 8
) (
    input  wire [N-1:0] req,
    output wire [N-1:0] grant,
    output wire         valid
);
    // 最低置位 = req & (-req)
    assign grant = req & (~req + {{(N-1){1'b0}}, 1'b1});
    assign valid = |req;
endmodule
