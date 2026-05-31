// NxN 交叉开关(crossbar)：每个输出口由 sel 选择任一输入口的数据（全连接）。
`timescale 1ns/1ps

module crossbar #(
    parameter integer N = 4,
    parameter integer W = 8
) (
    input  wire [N*W-1:0]          din,
    input  wire [N*$clog2(N)-1:0]  sel,    // 每个输出口的选择索引打包
    output reg  [N*W-1:0]          dout
);
    localparam integer SW = $clog2(N);
    integer o;
    reg [SW-1:0] s;
    always @(*) begin
        for (o = 0; o < N; o = o + 1) begin
            s = sel[o*SW +: SW];
            dout[o*W +: W] = din[s*W +: W];
        end
    end
endmodule
