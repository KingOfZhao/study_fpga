// SPI 主机（Mode 0：CPOL=0, CPHA=0）
//  - SCLK 空闲为低
//  - 数据在 SCLK 上升沿采样（MISO），下降沿切换（MOSI）
//  - MSB 优先，一次传输 8 位
// SCLK 频率 = clk / (2 * CLK_DIV)
`timescale 1ns/1ps

module spi_master #(
    parameter CLK_DIV = 4
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,     // 拉高一拍发起一次 8 位传输
    input  wire [7:0] tx_data,   // 要发送的字节
    input  wire       miso,      // 从机 -> 主机
    output reg        sclk,
    output reg        mosi,      // 主机 -> 从机
    output reg        cs_n,      // 片选，低有效
    output reg  [7:0] rx_data,   // 收到的字节
    output reg        busy,
    output reg        done       // 传输完成脉冲一拍
);
    localparam [1:0] IDLE = 2'd0, TRANSFER = 2'd1, FINISH = 2'd2;

    reg [1:0]  state;
    reg [15:0] div;
    reg [3:0]  sample_cnt;     // 已采样的位数 0..8
    reg [7:0]  shreg_tx, shreg_rx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            sclk       <= 1'b0;
            mosi       <= 1'b0;
            cs_n       <= 1'b1;
            rx_data    <= 8'd0;
            busy       <= 1'b0;
            done       <= 1'b0;
            div        <= 16'd0;
            sample_cnt <= 4'd0;
            shreg_tx   <= 8'd0;
            shreg_rx   <= 8'd0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    sclk       <= 1'b0;
                    cs_n       <= 1'b1;
                    busy       <= 1'b0;
                    div        <= 16'd0;
                    sample_cnt <= 4'd0;
                    if (start) begin
                        shreg_tx <= tx_data;
                        mosi     <= tx_data[7];   // 先放好 MSB
                        cs_n     <= 1'b0;
                        busy     <= 1'b1;
                        state    <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (div < CLK_DIV - 1)
                        div <= div + 1'b1;
                    else begin
                        div  <= 16'd0;
                        sclk <= ~sclk;
                        if (sclk == 1'b0) begin
                            // 即将上升沿：采样 MISO
                            shreg_rx   <= {shreg_rx[6:0], miso};
                            sample_cnt <= sample_cnt + 1'b1;
                            if (sample_cnt == 4'd7)
                                state <= FINISH;   // 第 8 位已采样
                        end else begin
                            // 即将下降沿：移出下一位到 MOSI
                            shreg_tx <= {shreg_tx[6:0], 1'b0};
                            mosi     <= shreg_tx[6];
                        end
                    end
                end

                FINISH: begin
                    sclk    <= 1'b0;
                    cs_n    <= 1'b1;
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    rx_data <= shreg_rx;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
