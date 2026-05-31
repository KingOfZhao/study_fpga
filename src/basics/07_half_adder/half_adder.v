// 半加器：两个 1 位相加，输出和 sum 与进位 cout（无进位输入）
`timescale 1ns/1ps

module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b;
    assign cout = a & b;
endmodule
