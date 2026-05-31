// 移动平均滤波器（FIR 的最简形式）—— 流水线 + 滑动窗口
// 输出 = 最近 N 个输入样本的平均值。N 取 2 的幂时除法即移位，非常省资源。
// 用"运行和"（running sum）做增量更新：新和 = 旧和 + 新样本 - 最旧样本。
`timescale 1ns/1ps

module fir_movavg #(
    parameter DW = 8,          // 样本位宽
    parameter N  = 4           // 抽头数（窗口长度，取 2 的幂）
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          valid_in,  // 输入样本有效
    input  wire [DW-1:0] x,
    output reg           valid_out, // 输出有效（比输入延迟 1 拍）
    output reg  [DW-1:0] y          // 移动平均结果
);
    localparam integer SW = DW + $clog2(N);   // 运行和位宽，防溢出

    reg [DW-1:0] taps [0:N-1];     // 最近 N 个样本
    reg [SW-1:0] sum;              // 运行和
    integer      i;

    // 显式零扩展到运行和位宽，保持位宽一致（lint 干净）
    wire [SW-1:0] x_ext   = {{(SW-DW){1'b0}}, x};
    wire [SW-1:0] old_ext = {{(SW-DW){1'b0}}, taps[N-1]};
    wire [SW-1:0] new_sum = sum + x_ext - old_ext;
    wire [SW-1:0] avg     = new_sum / N;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < N; i = i + 1) taps[i] <= {DW{1'b0}};
            sum       <= {SW{1'b0}};
            y         <= {DW{1'b0}};
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                sum <= new_sum;
                for (i = N-1; i > 0; i = i - 1) taps[i] <= taps[i-1];
                taps[0] <= x;
                y <= avg[DW-1:0];          // N 为 2 的幂 → 综合成右移
            end
        end
    end
endmodule
