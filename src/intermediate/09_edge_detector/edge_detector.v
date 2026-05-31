// 边沿检测：对输入信号同步打拍，输出上升沿/下降沿/任意沿的单拍脉冲
`timescale 1ns/1ps

module edge_detector (
    input  wire clk,
    input  wire rst_n,
    input  wire sig,
    output wire rise,
    output wire fall,
    output wire any_edge
);
    reg sig_d1, sig_d2;   // 两级同步（也起到打拍作用）

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_d1 <= 1'b0; sig_d2 <= 1'b0;
        end else begin
            sig_d1 <= sig;
            sig_d2 <= sig_d1;
        end
    end

    assign rise     =  sig_d1 & ~sig_d2;
    assign fall     = ~sig_d1 &  sig_d2;
    assign any_edge =  sig_d1 ^  sig_d2;
endmodule
