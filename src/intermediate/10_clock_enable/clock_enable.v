// 时钟使能发生器：每 DIV 个时钟产生 1 拍 tick（不真正分频时钟，用使能更利于综合/CDC）
`timescale 1ns/1ps

module clock_enable #(
    parameter integer DIV = 10
) (
    input  wire clk,
    input  wire rst_n,
    output reg  tick
);
    localparam integer CW = $clog2(DIV);
    localparam [CW-1:0] MAXC = DIV[CW-1:0] - 1'b1;
    reg [CW-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; tick <= 1'b0;
        end else if (cnt == MAXC) begin
            cnt <= 0; tick <= 1'b1;
        end else begin
            cnt <= cnt + 1'b1; tick <= 1'b0;
        end
    end
endmodule
