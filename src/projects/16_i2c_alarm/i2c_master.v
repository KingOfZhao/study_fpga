// 原子组件：I2C 主机（单字节读）
// 完成一次最简 I2C 读事务：START → 发 7 位地址+读位 → 收 ACK →
//   读 8 位数据 → 主机回 NACK → STOP。SDA 为开漏（只拉低/释放），SCL 由主机驱动。
//
// 时序：SDA 在 SCL 低电平期间变化，在 SCL 高电平期间有效（被采样）。
// SCL/SDA 输出寄存器化，保证单调跳变、无组合毛刺（开漏总线上尤其重要）。
`timescale 1ns/1ps

module i2c_master #(
    parameter integer DIV = 4        // 每个 SCL 1/4 周期占用的时钟数
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,         // 单拍脉冲：开始一次读事务
    input  wire [6:0] dev_addr,      // 7 位从机地址
    output reg  [7:0] data,          // 读回的字节
    output reg        done,          // 事务完成脉冲
    output reg        ack_err,       // 1=从机未应答地址
    // 开漏总线
    output reg        scl,           // 时钟（单主机，推挽即可）
    output reg        sda_oe,        // 1=把 SDA 拉低；0=释放（上拉为高）
    input  wire       sda_i          // 采样到的 SDA 电平
);
    localparam [2:0] IDLE=3'd0, START=3'd1, ADDR=3'd2, AACK=3'd3,
                     READ=3'd4, NACK=3'd5, STOP=3'd6, DONE=3'd7;

    localparam integer    DCW = (DIV <= 1) ? 1 : $clog2(DIV);
    localparam [DCW-1:0]  DLAST = (DCW)'(DIV - 1);

    reg [DCW-1:0] dc;
    wire q_en = (dc == DLAST);

    reg [2:0] state;
    reg [1:0] ph;        // SCL 一个 bit 内的 1/4 相位 0..3
    reg [3:0] bcnt;      // bit 计数
    reg [7:0] sh;        // 待发送移位寄存器（地址+读位），MSB 先
    reg [7:0] rxb;       // 接收移位寄存器
    reg       ackbit;

    wire addr_bit = sh[7];

    // 1/4 相位节拍发生器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) dc <= {DCW{1'b0}};
        else        dc <= q_en ? {DCW{1'b0}} : (dc + 1'b1);
    end

    // 组合：根据状态/相位算出本拍应有的 SCL 与 SDA 开漏电平
    reg scl_c, sda_oe_c;
    always @(*) begin
        scl_c    = 1'b1;
        sda_oe_c = 1'b0;          // 默认释放
        case (state)
            IDLE:  begin scl_c = 1'b1; sda_oe_c = 1'b0; end
            START: begin scl_c = 1'b1; sda_oe_c = 1'b1; end          // SCL 高时拉低 SDA = 起始
            ADDR:  begin scl_c = (ph == 2'd1) || (ph == 2'd2); sda_oe_c = (addr_bit == 1'b0); end
            AACK:  begin scl_c = (ph == 2'd1) || (ph == 2'd2); sda_oe_c = 1'b0; end  // 释放，等从机拉低
            READ:  begin scl_c = (ph == 2'd1) || (ph == 2'd2); sda_oe_c = 1'b0; end  // 释放，从机驱动
            NACK:  begin scl_c = (ph == 2'd1) || (ph == 2'd2); sda_oe_c = 1'b0; end  // 释放=高=NACK
            STOP:  begin scl_c = (ph != 2'd0); sda_oe_c = (ph <= 2'd1); end          // SCL 高时释放 SDA = 停止
            DONE:  begin scl_c = 1'b1; sda_oe_c = 1'b0; end
            default: begin scl_c = 1'b1; sda_oe_c = 1'b0; end
        endcase
    end

    // 寄存输出：消除组合毛刺与同一时刻的多次跳变
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl    <= 1'b1;
            sda_oe <= 1'b0;
        end else begin
            scl    <= scl_c;
            sda_oe <= sda_oe_c;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; ph <= 2'd0; bcnt <= 4'd0;
            sh <= 8'd0; rxb <= 8'd0; ackbit <= 1'b1;
            data <= 8'd0; done <= 1'b0; ack_err <= 1'b0;
        end else begin
            done <= 1'b0;
            if (state == IDLE) begin
                if (start) begin
                    sh    <= {dev_addr, 1'b1};   // 末位 1 = 读
                    bcnt  <= 4'd0;
                    ph    <= 2'd0;
                    state <= START;
                end
            end else if (q_en) begin
                // 采样点：SCL 高（ph==2）
                if (state == AACK && ph == 2'd2) ackbit <= sda_i;
                if (state == READ && ph == 2'd2) rxb <= {rxb[6:0], sda_i};

                if (ph == 2'd3) begin
                    ph <= 2'd0;
                    case (state)
                        START: begin state <= ADDR;  bcnt <= 4'd0; end
                        ADDR: begin
                            sh <= {sh[6:0], 1'b0};
                            if (bcnt == 4'd7) state <= AACK;
                            else              bcnt <= bcnt + 1'b1;
                        end
                        AACK: begin state <= READ; bcnt <= 4'd0; ack_err <= ackbit; end
                        READ: begin
                            if (bcnt == 4'd7) state <= NACK;
                            else              bcnt <= bcnt + 1'b1;
                        end
                        NACK: state <= STOP;
                        STOP: begin state <= DONE; data <= rxb; done <= 1'b1; end
                        DONE: state <= IDLE;
                        default: state <= IDLE;
                    endcase
                end else begin
                    ph <= ph + 1'b1;
                end
            end
        end
    end
endmodule
