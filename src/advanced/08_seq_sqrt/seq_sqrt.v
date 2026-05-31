// 整数平方根（逐位逼近）：W 位输入，W/2 拍算出 floor(sqrt(n))。
`timescale 1ns/1ps

module seq_sqrt #(
    parameter integer W = 16
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [W-1:0] num,
    output reg  [W/2-1:0] root,
    output reg          busy,
    output reg          done
);
    localparam integer STEPS = W/2;
    localparam integer CW = $clog2(STEPS) + 1;
    localparam [CW-1:0] LASTC = STEPS[CW-1:0] - 1'b1;

    reg [W-1:0]  rem;        // 剩余被开方数
    reg [W-1:0]  res;        // 当前结果(左移累积)
    reg [W-1:0]  bit_m;      // 当前测试位 (1<<(2k))
    reg [CW-1:0] cnt;

    wire [W-1:0] trial = res + bit_m;
    wire         ge    = (rem >= trial);
    wire [W-1:0] rem_n = ge ? (rem - trial) : rem;
    wire [W-1:0] res_n = ge ? ((res >> 1) + bit_m) : (res >> 1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rem <= 0; res <= 0; bit_m <= 0; cnt <= 0; busy <= 0; done <= 0; root <= 0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                rem   <= num;
                res   <= 0;
                bit_m <= {2'b01, {(W-2){1'b0}}};   // 1 << (W-2)
                cnt   <= 0;
                busy  <= 1'b1;
            end else if (busy) begin
                rem   <= rem_n;
                res   <= res_n;
                bit_m <= bit_m >> 2;
                cnt   <= cnt + 1'b1;
                if (cnt == LASTC) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    root <= res_n[W/2-1:0];
                end
            end
        end
    end
endmodule
