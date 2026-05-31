// 4 位数值比较器：输出 gt/eq/lt 三个标志（无符号比较）
`timescale 1ns/1ps

module comparator4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       gt,
    output wire       eq,
    output wire       lt
);
    assign gt = (a > b);
    assign eq = (a == b);
    assign lt = (a < b);
endmodule
