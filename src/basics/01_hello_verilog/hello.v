// 基础示例：4位计数器
// 功能：每个时钟上升沿 +1，可异步复位（低电平有效）
`timescale 1ns/1ps

module hello_counter (
    input  wire       clk,
    input  wire       rst_n,   // 低电平有效复位
    output reg  [3:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'b0;
        else
            count <= count + 1'b1;
    end

endmodule
