// APB-lite 从设备：内含寄存器堆，支持标准 APB 读/写时序（setup + access 两相）。
`timescale 1ns/1ps

module apb_regfile #(
    parameter integer AW = 4,    // 地址位宽 -> 2^AW 个寄存器
    parameter integer DW = 32
) (
    input  wire          pclk,
    input  wire          presetn,
    input  wire          psel,
    input  wire          penable,
    input  wire          pwrite,
    input  wire [AW-1:0] paddr,
    input  wire [DW-1:0] pwdata,
    output reg  [DW-1:0] prdata,
    output wire          pready
);
    reg [DW-1:0] regs [0:(1<<AW)-1];
    integer i;

    assign pready = 1'b1;        // 单周期访问，始终就绪

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            for (i = 0; i < (1<<AW); i = i + 1) regs[i] <= 0;
            prdata <= 0;
        end else begin
            // 写：access 相(psel & penable & pwrite)
            if (psel && penable && pwrite)
                regs[paddr] <= pwdata;
            // 读：access 相锁存
            if (psel && penable && !pwrite)
                prdata <= regs[paddr];
        end
    end
endmodule
