// 序列除法器（移位-相减，无符号）：W 拍算出商与余数。
`timescale 1ns/1ps

module seq_divider #(
    parameter integer W = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [W-1:0] dividend,
    input  wire [W-1:0] divisor,
    output reg  [W-1:0] quot,
    output reg  [W-1:0] rem,
    output reg          busy,
    output reg          done
);
    localparam integer CW = $clog2(W) + 1;
    localparam [CW-1:0] LASTC = W[CW-1:0] - 1'b1;

    reg [W:0]    r;          // 部分余数（W+1 位）
    reg [W-1:0]  q;
    reg [W-1:0]  d;
    reg [CW-1:0] cnt;

    wire [W:0]   r_sh    = {r[W-1:0], q[W-1]};
    wire         ge      = r_sh >= {1'b0, d};
    wire [W:0]   r_next  = ge ? (r_sh - {1'b0, d}) : r_sh;
    wire [W-1:0] q_next  = {q[W-2:0], ge};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r <= 0; q <= 0; d <= 0; cnt <= 0; busy <= 0; done <= 0; quot <= 0; rem <= 0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                r <= 0; q <= dividend; d <= divisor; cnt <= 0; busy <= 1'b1;
            end else if (busy) begin
                r   <= r_next;
                q   <= q_next;
                cnt <= cnt + 1'b1;
                if (cnt == LASTC) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    quot <= q_next;
                    rem  <= r_next[W-1:0];
                end
            end
        end
    end
endmodule
