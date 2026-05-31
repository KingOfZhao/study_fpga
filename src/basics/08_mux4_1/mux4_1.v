// 4:1 多路选择器（参数化位宽）：sel 选择 d0..d3 之一输出
`timescale 1ns/1ps

module mux4_1 #(
    parameter integer W = 8
) (
    input  wire [W-1:0] d0,
    input  wire [W-1:0] d1,
    input  wire [W-1:0] d2,
    input  wire [W-1:0] d3,
    input  wire [1:0]   sel,
    output reg  [W-1:0] y
);
    always @(*) begin
        case (sel)
            2'd0: y = d0;
            2'd1: y = d1;
            2'd2: y = d2;
            default: y = d3;
        endcase
    end
endmodule
