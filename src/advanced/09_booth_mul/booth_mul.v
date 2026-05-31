// Booth 基-2 有符号乘法器：W 拍算出 2W 位有符号乘积。
// 累加器高位用 W+1 位(多 1 个保护位)以避免最小负数(-2^(W-1))时溢出。
`timescale 1ns/1ps

module booth_mul #(
    parameter integer W = 8
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start,
    input  wire signed [W-1:0]  a,        // 被乘数
    input  wire signed [W-1:0]  b,        // 乘数
    output reg  signed [2*W-1:0] product,
    output reg                  busy,
    output reg                  done
);
    localparam integer CW = $clog2(W) + 1;
    localparam [CW-1:0] LASTC = W[CW-1:0] - 1'b1;

    // 位宽 2W+2：{高(W+1), 乘数(W), 附加位(1)}
    reg signed [2*W+1:0] A;
    reg signed [W-1:0]   m;
    reg [CW-1:0]         cnt;

    wire signed [2*W+1:0] addv  = {{m[W-1], m}, {(W+1){1'b0}}};
    wire signed [2*W+1:0] A_add = (A[1:0] == 2'b01) ? (A + addv) :
                                  (A[1:0] == 2'b10) ? (A - addv) : A;
    wire signed [2*W+1:0] A_next = A_add >>> 1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A <= 0; m <= 0; cnt <= 0; busy <= 0; done <= 0; product <= 0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                A    <= {{(W+1){1'b0}}, b, 1'b0};
                m    <= a;
                cnt  <= 0;
                busy <= 1'b1;
            end else if (busy) begin
                A   <= A_next;
                cnt <= cnt + 1'b1;
                if (cnt == LASTC) begin
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    product <= A_next[2*W:1];
                end
            end
        end
    end
endmodule
