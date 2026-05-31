// 单位 BCD 计数器：0..9 循环，到 9 产生进位脉冲 carry
`timescale 1ns/1ps

module bcd_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [3:0] bcd,
    output wire       carry
);
    assign carry = en && (bcd == 4'd9);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  bcd <= 4'd0;
        else if (en) bcd <= (bcd == 4'd9) ? 4'd0 : (bcd + 4'd1);
    end
endmodule
