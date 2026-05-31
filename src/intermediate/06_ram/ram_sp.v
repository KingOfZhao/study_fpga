// 单端口同步 RAM（会被综合工具映射成 FPGA 内部 Block RAM）
// 同步写：we=1 时在时钟沿把 din 写入 addr。
// 同步读：地址被时钟寄存，数据在下一拍出现在 dout（读延迟 1 拍）。
// 写读同址时为"读旧值"（read-first）行为。
`timescale 1ns/1ps

module ram_sp #(
    parameter DW = 8,          // 数据位宽
    parameter AW = 4           // 地址位宽 → 深度 2^AW
) (
    input  wire          clk,
    input  wire          we,
    input  wire [AW-1:0] addr,
    input  wire [DW-1:0] din,
    output reg  [DW-1:0] dout
);
    reg [DW-1:0] mem [0:(1<<AW)-1];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        dout <= mem[addr];     // 注册输出：读延迟 1 个时钟
    end
endmodule
