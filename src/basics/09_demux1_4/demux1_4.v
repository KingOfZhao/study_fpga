// 1:4 解复用器：把输入 d 送到 sel 选中的那一路，其余输出 0
`timescale 1ns/1ps

module demux1_4 #(
    parameter integer W = 8
) (
    input  wire [W-1:0] d,
    input  wire [1:0]   sel,
    output reg  [W-1:0] y0,
    output reg  [W-1:0] y1,
    output reg  [W-1:0] y2,
    output reg  [W-1:0] y3
);
    always @(*) begin
        y0 = {W{1'b0}};
        y1 = {W{1'b0}};
        y2 = {W{1'b0}};
        y3 = {W{1'b0}};
        case (sel)
            2'd0: y0 = d;
            2'd1: y1 = d;
            2'd2: y2 = d;
            default: y3 = d;
        endcase
    end
endmodule
