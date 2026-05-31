// 综合项目：I2C 传感器超阈报警 = i2c_master + 阈值比较器。
// 周期性(或受 go 触发)读取传感器字节，若读数 > threshold 则置位 alarm。
`timescale 1ns/1ps

module i2c_alarm #(
    parameter integer DIV      = 4,
    parameter [6:0]   DEV_ADDR = 7'h27
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       go,
    input  wire [7:0] threshold,
    output reg  [7:0] value,
    output reg        valid,      // 一次读完成脉冲
    output reg        alarm,
    output wire       ack_err,
    // 开漏总线
    output wire       scl,
    output wire       sda_oe,
    input  wire       sda_i
);
    wire [7:0] data;
    wire       done;

    i2c_master #(.DIV(DIV)) u_i2c (
        .clk(clk), .rst_n(rst_n), .start(go), .dev_addr(DEV_ADDR),
        .data(data), .done(done), .ack_err(ack_err),
        .scl(scl), .sda_oe(sda_oe), .sda_i(sda_i));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin value<=0; valid<=0; alarm<=0; end
        else begin
            valid <= 1'b0;
            if (done) begin
                value <= data;
                valid <= 1'b1;
                alarm <= (data > threshold);
            end
        end
    end
endmodule
