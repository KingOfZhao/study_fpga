// UART 接收器（8N1）
// 在起始位中点开始计时，之后每隔一个完整位宽在"位中点"采样，抗抖动。
`timescale 1ns/1ps

module uart_rx #(
    parameter CLKS_PER_BIT = 868
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_serial, // 串行输入（来自对端 TX）
    output reg        rx_dv,     // 收到一个字节，脉冲一拍
    output reg [7:0]  rx_byte
);
    localparam [2:0] IDLE  = 3'd0,
                     START = 3'd1,
                     DATA  = 3'd2,
                     STOP  = 3'd3,
                     CLEAN = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;

    // 两级寄存器同步外部异步输入，降低亚稳态风险
    reg rx_d1, rx_d2;
    always @(posedge clk) begin
        rx_d1 <= rx_serial;
        rx_d2 <= rx_d1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            rx_dv     <= 1'b0;
            rx_byte   <= 8'd0;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
        end else begin
            rx_dv <= 1'b0;       // 默认低，仅收完时脉冲一拍
            case (state)
                IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (rx_d2 == 1'b0)        // 检测到起始位下降
                        state <= START;
                end

                START: begin                 // 在起始位中点确认仍为 0
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx_d2 == 1'b0) begin
                            clk_count <= 16'd0;
                            state     <= DATA;
                        end else
                            state <= IDLE;   // 误触发，回到空闲
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                DATA: begin                  // 每隔一个位宽，在位中点采样
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count        <= 16'd0;
                        rx_byte[bit_index] <= rx_d2;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1'b1;
                        else begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin                  // 停止位结束，产生 rx_dv
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        rx_dv     <= 1'b1;
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
