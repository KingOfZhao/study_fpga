// 看门狗定时器：计数到 TIMEOUT 仍未被 kick 则输出 timeout(并自动复位计数)
`timescale 1ns/1ps

module watchdog #(
    parameter integer TIMEOUT = 16
) (
    input  wire clk,
    input  wire rst_n,
    input  wire kick,         // 喂狗：清零计数
    output reg  timeout
);
    localparam integer CW = $clog2(TIMEOUT);
    localparam [CW-1:0] LIMIT = TIMEOUT[CW-1:0] - 1'b1;
    reg [CW-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; timeout <= 1'b0;
        end else begin
            timeout <= 1'b0;
            if (kick) begin
                cnt <= 0;
            end else if (cnt == LIMIT) begin
                cnt     <= 0;
                timeout <= 1'b1;       // 超时脉冲
            end else cnt <= cnt + 1'b1;
        end
    end
endmodule
