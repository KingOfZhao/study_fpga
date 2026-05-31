// UART 自环：TX 串行输出直接接回 RX 串行输入，发什么就收到什么。
// 演示如何把已有原子模块组合成一个收发链路（用小 CLKS_PER_BIT 加速仿真）。
`timescale 1ns/1ps

module uart_loopback #(
    parameter integer CLKS_PER_BIT = 16
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_dv,
    input  wire [7:0] tx_byte,
    output wire       tx_active,
    output wire       tx_done,
    output wire       rx_dv,
    output wire [7:0] rx_byte,
    output wire       loop_serial   // 观察用：链路上的串行波形
);
    wire serial;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst_n(rst_n), .tx_dv(tx_dv), .tx_byte(tx_byte),
        .tx_active(tx_active), .tx_serial(serial), .tx_done(tx_done));

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk), .rst_n(rst_n), .rx_serial(serial),
        .rx_dv(rx_dv), .rx_byte(rx_byte));

    assign loop_serial = serial;
endmodule
