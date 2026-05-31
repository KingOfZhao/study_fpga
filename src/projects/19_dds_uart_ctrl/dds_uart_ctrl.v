// 综合项目：串口控制 DDS 频率 = uart_rx + dds。
// 通过 UART 收到的字节作为频率控制字(高位)，实时改变 DDS 输出波形频率。
`timescale 1ns/1ps

module dds_uart_ctrl #(
    parameter integer PA           = 12,
    parameter integer AW           = 6,
    parameter integer DW           = 8,
    parameter integer CLKS_PER_BIT = 8
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          rx_serial,
    output reg  [PA-1:0] fword,
    output wire [DW-1:0] wave
);
    wire       rx_dv;
    wire [7:0] rx_byte;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk), .rst_n(rst_n), .rx_serial(rx_serial), .rx_dv(rx_dv), .rx_byte(rx_byte));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) fword <= {PA{1'b0}};
        else if (rx_dv) fword <= {rx_byte, {(PA-8){1'b0}}};   // 字节左移到高位
    end

    dds #(.PA(PA), .AW(AW), .DW(DW)) u_dds (
        .clk(clk), .rst_n(rst_n), .en(1'b1), .fword(fword), .wave(wave));
endmodule
