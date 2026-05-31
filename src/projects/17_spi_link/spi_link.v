// 综合项目：SPI 主从全双工链路 = spi_master_modes(模式0) + spi_slave。
// 一次传输中主、从同时各发一字节、各收一字节（全双工）。
`timescale 1ns/1ps

module spi_link #(
    parameter integer DIV = 4
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] m_tx,       // 主机要发的字节
    input  wire [7:0] s_tx,       // 从机要发的字节
    output wire [7:0] m_rx,       // 主机收到(=s_tx)
    output wire [7:0] s_rx,       // 从机收到(=m_tx)
    output wire       s_rx_valid,
    output wire       busy,
    output wire       done
);
    wire sclk, cs_n, mosi, miso;

    spi_master_modes #(.DIV(DIV), .W(8)) u_m (
        .clk(clk), .rst_n(rst_n), .cpol(1'b0), .cpha(1'b0),
        .start(start), .tx(m_tx), .rx(m_rx), .busy(busy), .done(done),
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .miso(miso));

    spi_slave u_s (
        .clk(clk), .rst_n(rst_n), .sclk(sclk), .cs_n(cs_n), .mosi(mosi),
        .tx_byte(s_tx), .miso(miso), .rx_byte(s_rx), .rx_valid(s_rx_valid));
endmodule
