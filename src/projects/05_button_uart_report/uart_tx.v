// UART 发送器（8N1：1 起始位 + 8 数据位[LSB先] + 1 停止位）
// CLKS_PER_BIT = 时钟频率 / 波特率。例如 100MHz / 115200 ≈ 868。
`timescale 1ns/1ps

module uart_tx #(
    parameter CLKS_PER_BIT = 868
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_dv,     // 数据有效：拉高一拍即开始发送 tx_byte
    input  wire [7:0] tx_byte,
    output reg        tx_active, // 发送进行中
    output reg        tx_serial, // 串行输出（接到对端 RX）
    output reg        tx_done    // 一字节发送完成，脉冲一拍
);
    localparam [2:0] IDLE  = 3'd0,
                     START = 3'd1,
                     DATA  = 3'd2,
                     STOP  = 3'd3,
                     CLEAN = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  tx_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            tx_serial <= 1'b1;   // 空闲时线为高
            tx_active <= 1'b0;
            tx_done   <= 1'b0;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            tx_data   <= 8'd0;
        end else begin
            tx_done <= 1'b0;     // 默认低，仅完成时脉冲一拍
            case (state)
                IDLE: begin
                    tx_serial <= 1'b1;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (tx_dv) begin
                        tx_data   <= tx_byte;
                        tx_active <= 1'b1;
                        state     <= START;
                    end else begin
                        tx_active <= 1'b0;
                    end
                end

                START: begin               // 起始位 = 0
                    tx_serial <= 1'b0;
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count <= 16'd0;
                        state     <= DATA;
                    end
                end

                DATA: begin                // 8 个数据位，LSB 先
                    tx_serial <= tx_data[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count <= 16'd0;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1'b1;
                        else begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin                // 停止位 = 1
                    tx_serial <= 1'b1;
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        tx_done   <= 1'b1;
                        tx_active <= 1'b0;
                        clk_count <= 16'd0;
                        state     <= CLEAN;
                    end
                end

                CLEAN: state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end
endmodule
