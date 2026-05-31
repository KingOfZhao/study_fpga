// 时序逻辑基础：D 触发器 与 移位寄存器
`timescale 1ns/1ps

// 最基本的存储单元：D 触发器（同步复位）
// 每个时钟上升沿把输入 d "拍" 进寄存器 q
module dff (
    input  wire clk,
    input  wire rst,   // 高电平有效、同步复位
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule

// 串入并出移位寄存器（SIPO, Serial-In Parallel-Out）
// 每个时钟把 sin 移入最低位，整体左移；并行输出全部 N 位，serial_out 为最高位
module shift_reg #(
    parameter N = 8
) (
    input  wire         clk,
    input  wire         rst,        // 同步复位
    input  wire         sin,        // 串行输入
    output wire         serial_out, // 串行输出（最高位）
    output reg  [N-1:0] pout        // 并行输出
);
    always @(posedge clk) begin
        if (rst)
            pout <= {N{1'b0}};
        else
            pout <= {pout[N-2:0], sin};  // 左移，sin 进最低位
    end

    assign serial_out = pout[N-1];
endmodule
