// 输入捕获：测量输入脉冲的高电平宽度（以时钟数计），在下降沿输出 width+valid
`timescale 1ns/1ps

module pwm_capture #(
    parameter integer W = 16
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         sig,
    output reg  [W-1:0] width,    // 最近一个高脉冲的宽度（时钟数）
    output reg          valid
);
    reg s1, s2;
    wire rise = s1 & ~s2;
    wire fall = ~s1 & s2;

    reg [W-1:0] cnt;
    reg         counting;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1 <= 0; s2 <= 0; cnt <= 0; counting <= 0; width <= 0; valid <= 0;
        end else begin
            s1 <= sig; s2 <= s1;
            valid <= 1'b0;
            if (rise) begin
                counting <= 1'b1;
                cnt      <= {{(W-1){1'b0}}, 1'b1};   // 计入起始这一拍
            end else if (fall && counting) begin
                counting <= 1'b0;
                width    <= cnt;
                valid    <= 1'b1;
            end else if (counting) begin
                cnt <= cnt + 1'b1;
            end
        end
    end
endmodule
