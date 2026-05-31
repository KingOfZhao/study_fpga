// 全加器（组合逻辑）
module full_adder (
    input wire a,
    input wire b,
    input wire cin,   // 进位输入
    output wire sum,
    output wire cout  // 进位输出
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
