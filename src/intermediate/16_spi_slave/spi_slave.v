// SPI 从机（模式0：CPOL=0,CPHA=0），用系统时钟过采样 sclk/cs_n/mosi（推荐做法）。
// 上升沿采样 MOSI、下降沿更新 MISO；cs_n 下降沿装载待发送字节 tx_byte。
`timescale 1ns/1ps

module spi_slave (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sclk,
    input  wire       cs_n,
    input  wire       mosi,
    input  wire [7:0] tx_byte,
    output reg        miso,
    output reg  [7:0] rx_byte,
    output reg        rx_valid
);
    reg s1, s2, c1, c2, m1, m2;
    always @(posedge clk) begin
        s1 <= sclk; s2 <= s1;
        c1 <= cs_n; c2 <= c1;
        m1 <= mosi; m2 <= m1;
    end
    wire sclk_rise = s1 & ~s2;
    wire sclk_fall = ~s1 & s2;
    wire cs_fall   = ~c1 & c2;
    wire cs_active = ~c2;

    reg [7:0] rxsh, txsh;
    reg [3:0] bitcnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rxsh <= 0; txsh <= 0; bitcnt <= 0;
            miso <= 1'b0; rx_byte <= 0; rx_valid <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            if (cs_fall) begin
                txsh   <= tx_byte;
                miso   <= tx_byte[7];
                bitcnt <= 0;
            end else if (cs_active) begin
                if (sclk_rise) begin
                    rxsh   <= {rxsh[6:0], m2};
                    bitcnt <= bitcnt + 4'd1;
                    if (bitcnt == 4'd7) begin
                        rx_byte  <= {rxsh[6:0], m2};
                        rx_valid <= 1'b1;
                        bitcnt   <= 0;
                    end
                end
                if (sclk_fall) begin
                    txsh <= {txsh[6:0], 1'b0};
                    miso <= txsh[6];
                end
            end
        end
    end
endmodule
