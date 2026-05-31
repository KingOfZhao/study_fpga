// 综合项目：曼彻斯特编解码链路 = manchester_enc -> 信道 -> manchester_dec。
// 编码器串行发出 chip 流，解码器同节拍接收并还原原始字节，并校验编码合法性。
`timescale 1ns/1ps

module manchester_link (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] tx_data,
    output wire       tx_done,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       code_err
);
    wire chip, active;

    manchester_enc u_enc (
        .clk(clk), .rst_n(rst_n), .start(start), .data(tx_data),
        .tx(chip), .active(active), .done(tx_done));

    manchester_dec u_dec (
        .clk(clk), .rst_n(rst_n), .chip(chip), .chip_valid(active),
        .data(rx_data), .data_valid(rx_valid), .code_err(code_err));
endmodule
