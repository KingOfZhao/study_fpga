// 秒表：run 时每个 tick(=1 秒脉冲) 走一秒，BCD 显示 分:秒(mm:ss)，clr 清零
`timescale 1ns/1ps

module stopwatch (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       run,
    input  wire       clr,
    input  wire       tick,        // 外部 1Hz 脉冲（仿真里直接给）
    output reg  [3:0] sec_ones,
    output reg  [3:0] sec_tens,
    output reg  [3:0] min_ones,
    output reg  [3:0] min_tens
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sec_ones <= 0; sec_tens <= 0; min_ones <= 0; min_tens <= 0;
        end else if (clr) begin
            sec_ones <= 0; sec_tens <= 0; min_ones <= 0; min_tens <= 0;
        end else if (run && tick) begin
            if (sec_ones == 4'd9) begin
                sec_ones <= 0;
                if (sec_tens == 4'd5) begin
                    sec_tens <= 0;
                    if (min_ones == 4'd9) begin
                        min_ones <= 0;
                        min_tens <= (min_tens == 4'd5) ? 4'd0 : (min_tens + 4'd1);
                    end else min_ones <= min_ones + 4'd1;
                end else sec_tens <= sec_tens + 4'd1;
            end else sec_ones <= sec_ones + 4'd1;
        end
    end
endmodule
