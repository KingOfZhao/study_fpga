// 一阶 Sigma-Delta DAC：累加器溢出产生 1-bit 比特流，其平均密度 ≈ level/2^N。
// 配一个简单 RC 低通即可还原模拟电压。
`timescale 1ns/1ps

module sigma_delta_dac #(
    parameter integer N = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [N-1:0] level,
    output reg          bitstream
);
    reg [N:0] acc;        // N+1 位，最高位为进位
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= 0; bitstream <= 1'b0;
        end else begin
            acc       <= {1'b0, acc[N-1:0]} + {1'b0, level};
            bitstream <= acc[N];
        end
    end
endmodule
