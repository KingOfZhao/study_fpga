// 可逆计数器：up=1 加，down=1 减；带使能与溢出回绕
`timescale 1ns/1ps

module updown_counter #(
    parameter integer W = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         en,
    input  wire         up_down,   // 1=加, 0=减
    output reg  [W-1:0] cnt
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      cnt <= {W{1'b0}};
        else if (en)     cnt <= up_down ? (cnt + 1'b1) : (cnt - 1'b1);
    end
endmodule
