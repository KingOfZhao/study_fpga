// ALU（算术逻辑单元）—— 纯组合逻辑
// 一个端口宽度可参数化的运算器：根据 op 选择不同运算。
// y = f(a, b)；zero 表示结果为 0；carry 仅对加/减有效（进位/借位）。
`timescale 1ns/1ps

module alu #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       op,    // 运算选择
    output reg  [WIDTH-1:0] y,     // 运算结果
    output wire             zero,  // 结果是否为 0
    output reg              carry  // 加法进位 / 减法借位
);
    // 运算编码
    localparam OP_ADD = 3'd0,
               OP_SUB = 3'd1,
               OP_AND = 3'd2,
               OP_OR  = 3'd3,
               OP_XOR = 3'd4,
               OP_SLT = 3'd5,   // set-less-than（无符号）
               OP_SHL = 3'd6,   // 逻辑左移 b 位
               OP_SHR = 3'd7;   // 逻辑右移 b 位

    reg [WIDTH:0] ext;           // 多一位用于捕获进位/借位

    always @(*) begin
        // 默认值，避免推断出锁存器（latch）
        y     = {WIDTH{1'b0}};
        carry = 1'b0;
        ext   = {(WIDTH+1){1'b0}};
        case (op)
            OP_ADD: begin ext = {1'b0, a} + {1'b0, b}; y = ext[WIDTH-1:0]; carry = ext[WIDTH]; end
            OP_SUB: begin ext = {1'b0, a} - {1'b0, b}; y = ext[WIDTH-1:0]; carry = ext[WIDTH]; end
            OP_AND: y = a & b;
            OP_OR:  y = a | b;
            OP_XOR: y = a ^ b;
            OP_SLT: y = (a < b) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
            OP_SHL: y = a << b;
            OP_SHR: y = a >> b;
            default: y = {WIDTH{1'b0}};
        endcase
    end

    assign zero = (y == {WIDTH{1'b0}});
endmodule
