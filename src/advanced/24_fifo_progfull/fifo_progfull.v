// 带可编程几乎满/几乎空标志的同步 FIFO，并输出当前计数。
// 用于流控：prog_full 提前告知上游减速，prog_empty 提示下游数据将尽。
`timescale 1ns/1ps

module fifo_progfull #(
    parameter integer DW     = 8,
    parameter integer AW     = 4,    // 深度 2^AW
    parameter integer AFULL  = 12,   // 几乎满阈值
    parameter integer AEMPTY = 2     // 几乎空阈值
) (
    input  wire          clk, rst_n,
    input  wire          wr,
    input  wire [DW-1:0] din,
    input  wire          rd,
    output wire [DW-1:0] dout,
    output wire          full,
    output wire          empty,
    output wire          prog_full,
    output wire          prog_empty,
    output wire [AW:0]   count
);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    reg [AW:0]   wptr, rptr;

    assign empty = (wptr == rptr);
    assign full  = (wptr[AW] != rptr[AW]) && (wptr[AW-1:0] == rptr[AW-1:0]);
    assign count = wptr - rptr;
    assign dout  = mem[rptr[AW-1:0]];
    assign prog_full  = (count >= AFULL[AW:0]);
    assign prog_empty = (count <= AEMPTY[AW:0]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin wptr<=0; rptr<=0; end
        else begin
            if (wr && !full)  begin mem[wptr[AW-1:0]] <= din; wptr <= wptr + 1'b1; end
            if (rd && !empty) rptr <= rptr + 1'b1;
        end
    end
endmodule
