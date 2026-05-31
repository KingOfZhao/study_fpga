// 线性反馈移位寄存器（8 位，最大长度，多项式 x^8+x^6+x^5+x^4+1）
// 伪随机序列发生器，周期 255（非零状态）
`timescale 1ns/1ps

module lfsr (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [7:0] state
);
    wire fb = state[7] ^ state[5] ^ state[4] ^ state[3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  state <= 8'hFF;             // 非零种子
        else if (en) state <= {state[6:0], fb};
    end
endmodule
