// 曼彻斯特解码器：按 chip_valid 节拍接收 chip，每 2 个 chip 还原 1 个数据位(LSB先)
// 同时校验两 chip 是否互补(bit,~bit)，否则置 code_err
`timescale 1ns/1ps

module manchester_dec (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       chip,
    input  wire       chip_valid,
    output reg  [7:0] data,
    output reg        data_valid,
    output reg        code_err
);
    reg [3:0] cnt;        // 已收 chip 数 0..15
    reg [7:0] sh;
    reg       first;      // 上一 chip（phase0 的值）

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; sh <= 0; first <= 0;
            data <= 0; data_valid <= 0; code_err <= 0;
        end else begin
            data_valid <= 1'b0;
            code_err   <= 1'b0;
            if (chip_valid) begin
                if (cnt[0] == 1'b0) begin
                    // phase0：记录该位的值
                    first <= chip;
                end else begin
                    // phase1：应为 ~first，否则编码错误
                    if (chip == first) code_err <= 1'b1;
                    sh <= {first, sh[7:1]};       // LSB 先：右移入
                end
                if (cnt == 4'd15) begin
                    cnt        <= 0;
                    data       <= {first, sh[7:1]};
                    data_valid <= 1'b1;
                end else cnt <= cnt + 4'd1;
            end
        end
    end
endmodule
