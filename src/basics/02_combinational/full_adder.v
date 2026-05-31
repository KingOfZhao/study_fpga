// 全加器（组合逻辑）
// 输入 a, b, cin；输出 sum 和进位 cout。{cout,sum} = a + b + cin
`timescale 1ns/1ps

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,   // 进位输入
    output wire sum,
    output wire cout   // 进位输出
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
