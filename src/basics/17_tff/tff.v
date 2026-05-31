// T 触发器：t=1 时每个时钟翻转，t=0 保持。异步复位
`timescale 1ns/1ps

module tff (
    input  wire clk,
    input  wire rst_n,
    input  wire t,
    output reg  q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else if (t) q <= ~q;
    end
endmodule
