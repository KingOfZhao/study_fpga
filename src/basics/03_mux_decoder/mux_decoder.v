// 组合逻辑进阶：多路选择器（MUX）与译码器（Decoder）
`timescale 1ns/1ps

// 4 选 1 多路选择器，数据位宽可参数化
module mux4to1 #(
    parameter WIDTH = 4
) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire [WIDTH-1:0] d2,
    input  wire [WIDTH-1:0] d3,
    input  wire [1:0]       sel,
    output reg  [WIDTH-1:0] y
);
    // 用 always @(*) + case 描述组合逻辑：注意所有分支都要赋值，避免生成锁存器
    always @(*) begin
        case (sel)
            2'b00:   y = d0;
            2'b01:   y = d1;
            2'b10:   y = d2;
            2'b11:   y = d3;
            default: y = {WIDTH{1'b0}};
        endcase
    end
endmodule

// 2-4 译码器，带使能 en，输出 one-hot（仅一位为 1）
module decoder2to4 (
    input  wire       en,
    input  wire [1:0] a,
    output reg  [3:0] y
);
    always @(*) begin
        if (!en)
            y = 4'b0000;          // 未使能时输出全 0
        else
            y = 4'b0001 << a;     // a=0->0001, a=1->0010, a=2->0100, a=3->1000
    end
endmodule
