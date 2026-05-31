// JK 触发器：00 保持 / 01 置 0 / 10 置 1 / 11 翻转。异步复位
`timescale 1ns/1ps

module jkff (
    input  wire clk,
    input  wire rst_n,
    input  wire j,
    input  wire k,
    output reg  q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else case ({j, k})
            2'b00: q <= q;
            2'b01: q <= 1'b0;
            2'b10: q <= 1'b1;
            default: q <= ~q;
        endcase
    end
endmodule
