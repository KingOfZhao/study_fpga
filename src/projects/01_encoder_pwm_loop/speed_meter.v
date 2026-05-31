// 原子组件：测速（固定窗口计数）
// 在每 WIN 个时钟为一个测量窗口，统计窗口内 tick（步进）个数作为"转速"，
// 窗口结束时锁存 speed 并产生单周期 sample 脉冲。
`timescale 1ns/1ps

module speed_meter #(
    parameter integer WIN  = 512,   // 测量窗口（时钟数）
    parameter integer SPDW = 9      // speed 位宽
) (
    input  wire            clk,
    input  wire            rst_n,
    input  wire            tick,
    output reg  [SPDW-1:0] speed,    // 上一窗口的步进计数
    output reg             sample    // 窗口结束脉冲（speed 已更新）
);
    localparam integer    CW   = (WIN <= 2) ? 1 : $clog2(WIN);
    localparam [CW-1:0]   LAST = (CW)'(WIN - 1);

    reg [CW-1:0]   cnt;
    reg [SPDW-1:0] acc;

    wire [SPDW-1:0] tick_ext = {{(SPDW-1){1'b0}}, tick};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt    <= {CW{1'b0}};
            acc    <= {SPDW{1'b0}};
            speed  <= {SPDW{1'b0}};
            sample <= 1'b0;
        end else begin
            sample <= 1'b0;
            if (cnt == LAST) begin
                speed  <= acc + tick_ext;   // 计入当前拍
                acc    <= {SPDW{1'b0}};
                cnt    <= {CW{1'b0}};
                sample <= 1'b1;
            end else begin
                cnt <= cnt + 1'b1;
                acc <= acc + tick_ext;
            end
        end
    end
endmodule
