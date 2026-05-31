// 占空比测量：测一个周期内的高电平时钟数与总周期时钟数，输出 duty(0..100 %)
`timescale 1ns/1ps

module duty_measure #(
    parameter integer W = 16
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         sig,
    output reg  [7:0]   duty,       // 百分比 0..100
    output reg  [W-1:0] period,
    output reg          valid
);
    reg sig_d1, sig_d2;
    wire rise = sig_d1 & ~sig_d2;

    reg [W-1:0] pcnt, hcnt;
    reg         started;

    wire [W+7:0] hmul = hcnt * 100;
    wire [W+7:0] draw = (pcnt == 0) ? {(W+8){1'b0}} : (hmul / {8'd0, pcnt});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_d1 <= 0; sig_d2 <= 0;
            pcnt <= 0; hcnt <= 0; started <= 0;
            duty <= 0; period <= 0; valid <= 0;
        end else begin
            sig_d1 <= sig; sig_d2 <= sig_d1;
            valid  <= 1'b0;
            if (rise) begin
                if (started) begin
                    period <= pcnt;
                    duty   <= draw[7:0];
                    valid  <= 1'b1;
                end
                started <= 1'b1;
                pcnt    <= {{(W-1){1'b0}}, 1'b1};
                hcnt    <= {{(W-1){1'b0}}, sig_d1};
            end else if (started) begin
                pcnt <= pcnt + 1'b1;
                if (sig_d1) hcnt <= hcnt + 1'b1;
            end
        end
    end
endmodule
