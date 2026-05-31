// 频率计：在 GATE 个时钟的闸门窗口内统计输入信号的上升沿数，窗口结束输出 freq+done
`timescale 1ns/1ps

module freq_counter #(
    parameter integer GATE = 100,
    parameter integer W    = 16
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         sig,
    output reg  [W-1:0] freq,
    output reg          done
);
    reg sig_d1, sig_d2;             // 同步 + 边沿检测
    wire sig_rise = sig_d1 & ~sig_d2;

    localparam integer GW = $clog2(GATE);
    localparam [GW-1:0] GLIM = GATE[GW-1:0] - 1'b1;
    reg [GW-1:0] gate_cnt;
    reg [W-1:0]  edge_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_d1 <= 0; sig_d2 <= 0;
            gate_cnt <= 0; edge_cnt <= 0; freq <= 0; done <= 1'b0;
        end else begin
            sig_d1 <= sig; sig_d2 <= sig_d1;
            done <= 1'b0;
            if (gate_cnt == GLIM) begin
                freq     <= edge_cnt + {{(W-1){1'b0}}, sig_rise};
                done     <= 1'b1;
                gate_cnt <= 0;
                edge_cnt <= 0;
            end else begin
                gate_cnt <= gate_cnt + 1'b1;
                if (sig_rise) edge_cnt <= edge_cnt + 1'b1;
            end
        end
    end
endmodule
