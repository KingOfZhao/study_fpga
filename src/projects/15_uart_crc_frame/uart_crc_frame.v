// 综合项目：带 CRC 校验的 UART 帧收发 = crc8 + uart_tx + uart_rx。
// 发送端：对数据字节算 CRC-8，依次发出 [数据][CRC]；
// 接收端：收两字节，对数据重算 CRC 并与收到的 CRC 比对，输出 crc_ok。
`timescale 1ns/1ps

module uart_crc_frame #(
    parameter integer CLKS_PER_BIT = 8
) (
    input  wire       clk,
    input  wire       rst_n,
    // 发送
    input  wire       send,
    input  wire [7:0] data_in,
    output wire       tx_serial,
    // 接收
    input  wire       rx_serial,
    output reg  [7:0] data_out,
    output reg        frame_valid,
    output reg        crc_ok
);
    // ---------- 发送端 ----------
    reg  [2:0] tst;
    reg  [3:0] tbidx;
    reg  [7:0] tdata;
    reg        tx_clr, tx_bv, tx_bit, tx_dv;
    reg  [7:0] tx_byte;
    wire       tx_done, tx_active;
    wire [7:0] tx_crc_val;

    crc8 u_txcrc (.clk(clk), .rst_n(rst_n), .clr(tx_clr),
        .bit_in(tx_bit), .bit_valid(tx_bv), .crc(tx_crc_val));
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst_n(rst_n), .tx_dv(tx_dv), .tx_byte(tx_byte),
        .tx_active(tx_active), .tx_serial(tx_serial), .tx_done(tx_done));

    localparam T_IDLE=0, T_CRC=1, T_SENDD=2, T_WAITD=3, T_SENDC=4, T_WAITC=5;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin tst<=T_IDLE; tbidx<=0; tdata<=0; tx_clr<=0; tx_bv<=0; tx_bit<=0; tx_dv<=0; tx_byte<=0; end
        else begin
            tx_clr<=1'b0; tx_bv<=1'b0; tx_dv<=1'b0;
            case (tst)
                T_IDLE: if (send) begin tdata<=data_in; tx_clr<=1'b1; tbidx<=0; tst<=T_CRC; end
                T_CRC: begin
                    tx_bv<=1'b1; tx_bit<=tdata[7-tbidx];
                    if (tbidx==4'd7) tst<=T_SENDD; else tbidx<=tbidx+1'b1;
                end
                T_SENDD: begin tx_byte<=tdata; tx_dv<=1'b1; tst<=T_WAITD; end
                T_WAITD: if (tx_done) tst<=T_SENDC;
                T_SENDC: begin tx_byte<=tx_crc_val; tx_dv<=1'b1; tst<=T_WAITC; end
                T_WAITC: if (tx_done) tst<=T_IDLE;
                default: tst<=T_IDLE;
            endcase
        end
    end

    // ---------- 接收端 ----------
    wire       rx_dv;
    wire [7:0] rx_byte;
    reg  [1:0] rst2;
    reg  [3:0] rbidx;
    reg        rx_clr, rx_bv, rx_bit;
    wire [7:0] rx_crc_val;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk), .rst_n(rst_n), .rx_serial(rx_serial), .rx_dv(rx_dv), .rx_byte(rx_byte));
    crc8 u_rxcrc (.clk(clk), .rst_n(rst_n), .clr(rx_clr),
        .bit_in(rx_bit), .bit_valid(rx_bv), .crc(rx_crc_val));

    localparam R_DATA=0, R_FEED=1, R_WAITC=2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin rst2<=R_DATA; rbidx<=0; rx_clr<=0; rx_bv<=0; rx_bit<=0; data_out<=0; frame_valid<=0; crc_ok<=0; end
        else begin
            rx_clr<=1'b0; rx_bv<=1'b0; frame_valid<=1'b0;
            case (rst2)
                R_DATA: if (rx_dv) begin data_out<=rx_byte; rx_clr<=1'b1; rbidx<=0; rst2<=R_FEED; end
                R_FEED: begin
                    rx_bv<=1'b1; rx_bit<=data_out[7-rbidx];
                    if (rbidx==4'd7) rst2<=R_WAITC; else rbidx<=rbidx+1'b1;
                end
                R_WAITC: if (rx_dv) begin
                    crc_ok      <= (rx_byte == rx_crc_val);
                    frame_valid <= 1'b1;
                    rst2        <= R_DATA;
                end
                default: rst2<=R_DATA;
            endcase
        end
    end
endmodule
