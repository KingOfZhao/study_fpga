// 组合案例 02：I2C 读传感器 + UART 上报
// 真实工程里最常见的"采集→上报"链路：FPGA 用 I2C 读温度/气压等传感器寄存器，
// 再用 UART 把数据发给上位机/PC。
//
//   go ─▶[i2c_master]──data──▶[FSM 触发]──tx_byte/tx_dv──▶[uart_tx]──▶ tx_serial ─▶ PC
//          ▲  SCL/SDA 开漏总线
//          └─ 传感器（I2C 从机）
`timescale 1ns/1ps

module i2c_sensor_uart #(
    parameter integer DIV          = 4,   // I2C 速率（SCL 1/4 周期时钟数）
    parameter integer CLKS_PER_BIT = 8,   // UART 波特率（=时钟/波特率）
    parameter [6:0]   DEV_ADDR     = 7'h27
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       go,            // 单拍脉冲：发起一次"读+上报"
    output reg  [7:0] sensor_byte,   // 读到的传感器字节
    output reg        busy,          // 事务进行中
    output reg        done,          // 全流程完成脉冲
    output wire       ack_err,       // I2C 地址未应答
    // I2C 开漏总线
    output wire       scl,
    output wire       sda_oe,
    input  wire       sda_i,
    // UART
    output wire       tx_serial,
    output wire       tx_active
);
    localparam [2:0] S_IDLE=3'd0, S_RD=3'd1, S_WAITRD=3'd2,
                     S_TX=3'd3, S_WAITTX=3'd4, S_FIN=3'd5;

    reg        i2c_start;
    wire [7:0] i2c_data;
    wire       i2c_done;

    reg        tx_dv;
    wire       tx_done;

    reg [2:0]  state;

    i2c_master #(.DIV(DIV)) u_i2c (
        .clk(clk), .rst_n(rst_n),
        .start(i2c_start), .dev_addr(DEV_ADDR),
        .data(i2c_data), .done(i2c_done), .ack_err(ack_err),
        .scl(scl), .sda_oe(sda_oe), .sda_i(sda_i)
    );

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart (
        .clk(clk), .rst_n(rst_n),
        .tx_dv(tx_dv), .tx_byte(sensor_byte),
        .tx_active(tx_active), .tx_serial(tx_serial), .tx_done(tx_done)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            i2c_start   <= 1'b0;
            tx_dv       <= 1'b0;
            sensor_byte <= 8'd0;
            busy        <= 1'b0;
            done        <= 1'b0;
        end else begin
            i2c_start <= 1'b0;
            tx_dv     <= 1'b0;
            done      <= 1'b0;
            case (state)
                S_IDLE: begin
                    busy <= 1'b0;
                    if (go) begin
                        i2c_start <= 1'b1;   // 触发 I2C 读
                        busy      <= 1'b1;
                        state     <= S_RD;
                    end
                end
                S_RD: state <= S_WAITRD;       // 等 start 被采纳
                S_WAITRD: if (i2c_done) begin
                    sensor_byte <= i2c_data;   // 锁存传感器数据
                    state       <= S_TX;
                end
                S_TX: begin
                    tx_dv <= 1'b1;             // 触发 UART 发送
                    if (tx_active) begin
                        tx_dv <= 1'b0;
                        state <= S_WAITTX;
                    end
                end
                S_WAITTX: if (tx_done) begin
                    done  <= 1'b1;
                    state <= S_FIN;
                end
                S_FIN: begin
                    busy  <= 1'b0;
                    state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
