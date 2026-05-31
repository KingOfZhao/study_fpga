// 综合项目：UART 回显器 = uart_rx + sync_fifo + uart_tx。
// 收到的字节进 FIFO 缓冲，再逐字节经 UART 发回，实现带缓冲的回显（解耦收/发速率）。
`timescale 1ns/1ps

module uart_echo #(
    parameter integer CLKS_PER_BIT = 8,
    parameter integer DEPTH        = 16
) (
    input  wire clk,
    input  wire rst_n,
    input  wire rx_serial,
    output wire tx_serial,
    output wire tx_active
);
    wire       rx_dv;
    wire [7:0] rx_byte;
    wire       full, empty;
    wire [7:0] fifo_dout;
    wire [$clog2(DEPTH):0] count;

    reg        rd_en, tx_dv;
    reg  [7:0] tx_byte;
    reg  [2:0] st;
    wire       tx_done;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk), .rst_n(rst_n), .rx_serial(rx_serial),
        .rx_dv(rx_dv), .rx_byte(rx_byte));

    sync_fifo #(.WIDTH(8), .DEPTH(DEPTH)) u_fifo (
        .clk(clk), .rst_n(rst_n),
        .wr_en(rx_dv && !full), .wr_data(rx_byte),
        .rd_en(rd_en), .rd_data(fifo_dout),
        .full(full), .empty(empty), .count(count));

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst_n(rst_n), .tx_dv(tx_dv), .tx_byte(tx_byte),
        .tx_active(tx_active), .tx_serial(tx_serial), .tx_done(tx_done));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin rd_en<=0; tx_dv<=0; tx_byte<=0; st<=0; end
        else begin
            rd_en<=0; tx_dv<=0;
            case (st)
                3'd0: if (!empty && !tx_active) begin rd_en<=1'b1; st<=3'd1; end
                3'd1: st<=3'd2;                          // 等同步 FIFO 读延迟
                3'd2: begin tx_byte<=fifo_dout; tx_dv<=1'b1; st<=3'd3; end
                3'd3: st<=3'd4;                          // tx 进入忙
                3'd4: if (tx_done) st<=3'd0;
                default: st<=3'd0;
            endcase
        end
    end
endmodule
