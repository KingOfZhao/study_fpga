// 异步 FIFO（跨时钟域）：格雷码指针 + 两级同步器，first-word-fall-through 读
// 经典 Cliff Cummings 结构。full/empty 寄存器化，避免组合反馈环。DEPTH = 2^AW。
`timescale 1ns/1ps

module async_fifo #(
    parameter integer W  = 8,
    parameter integer AW = 4
) (
    // 写时钟域
    input  wire         wr_clk,
    input  wire         wr_rst_n,
    input  wire         wr_en,
    input  wire [W-1:0] wr_data,
    output reg          wr_full,
    // 读时钟域
    input  wire         rd_clk,
    input  wire         rd_rst_n,
    input  wire         rd_en,
    output reg          rd_empty,
    output wire [W-1:0] rd_data
);
    localparam integer DEPTH = (1 << AW);
    reg [W-1:0] mem [0:DEPTH-1];

    reg  [AW:0] wr_bin, wr_gray;
    reg  [AW:0] rd_bin, rd_gray;
    reg  [AW:0] wr_gray_s1, wr_gray_s2;   // wr_gray 同步到读时钟域
    reg  [AW:0] rd_gray_s1, rd_gray_s2;   // rd_gray 同步到写时钟域

    wire        do_wr = wr_en & ~wr_full;
    wire        do_rd = rd_en & ~rd_empty;
    wire [AW:0] wr_bin_next  = wr_bin + {{AW{1'b0}}, do_wr};
    wire [AW:0] wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
    wire [AW:0] rd_bin_next  = rd_bin + {{AW{1'b0}}, do_rd};
    wire [AW:0] rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;

    wire full_next  = (wr_gray_next == {~rd_gray_s2[AW:AW-1], rd_gray_s2[AW-2:0]});
    wire empty_next = (rd_gray_next == wr_gray_s2);

    // 写指针 + 写内存 + 寄存 full
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_bin <= 0; wr_gray <= 0; wr_full <= 1'b0;
        end else begin
            if (do_wr) mem[wr_bin[AW-1:0]] <= wr_data;
            wr_bin  <= wr_bin_next;
            wr_gray <= wr_gray_next;
            wr_full <= full_next;
        end
    end

    // 读指针 + 寄存 empty
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_bin <= 0; rd_gray <= 0; rd_empty <= 1'b1;
        end else begin
            rd_bin   <= rd_bin_next;
            rd_gray  <= rd_gray_next;
            rd_empty <= empty_next;
        end
    end

    // 两级同步器
    always @(posedge rd_clk or negedge rd_rst_n)
        if (!rd_rst_n) {wr_gray_s2, wr_gray_s1} <= 0;
        else           {wr_gray_s2, wr_gray_s1} <= {wr_gray_s1, wr_gray};

    always @(posedge wr_clk or negedge wr_rst_n)
        if (!wr_rst_n) {rd_gray_s2, rd_gray_s1} <= 0;
        else           {rd_gray_s2, rd_gray_s1} <= {rd_gray_s1, rd_gray};

    assign rd_data = mem[rd_bin[AW-1:0]];   // FWFT
endmodule
