// 后进先出栈 LIFO：push 压栈，pop 出栈，带 full/empty 标志
`timescale 1ns/1ps

module stack_lifo #(
    parameter integer W     = 8,
    parameter integer DEPTH = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         push,
    input  wire         pop,
    input  wire [W-1:0] din,
    output wire [W-1:0] dout,   // 栈顶
    output wire         full,
    output wire         empty
);
    localparam integer PW = $clog2(DEPTH);
    reg [W-1:0]  mem [0:DEPTH-1];
    reg [PW:0]   sp;            // 栈指针 = 元素个数（0..DEPTH）

    wire [PW-1:0] top_idx = sp[PW-1:0] - 1'b1;   // 栈顶元素地址
    assign empty = (sp == 0);
    assign full  = (sp == DEPTH[PW:0]);
    assign dout  = (sp == 0) ? {W{1'b0}} : mem[top_idx];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sp <= 0;
        else begin
            // 同一拍只允许一种操作（push 优先），简化语义
            if (push && !full) begin
                mem[sp[PW-1:0]] <= din;
                sp <= sp + 1'b1;
            end else if (pop && !empty) begin
                sp <= sp - 1'b1;
            end
        end
    end
endmodule
