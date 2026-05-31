// PS/2 接收器：设备提供 ps2_clk，数据在 ps2_clk 下降沿有效。
// 帧 = 起始位(0) + 8 数据位(LSB先) + 奇校验 + 停止位(1)。用系统时钟过采样。
`timescale 1ns/1ps

module ps2_rx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ps2_clk,
    input  wire       ps2_data,
    output reg  [7:0] data,
    output reg        valid,
    output reg        err       // 校验/帧错误
);
    reg c1, c2, c3, d1, d2;
    always @(posedge clk) begin
        c1 <= ps2_clk;  c2 <= c1; c3 <= c2;
        d1 <= ps2_data; d2 <= d1;
    end
    wire clk_fall = c3 & ~c2;     // ps2_clk 下降沿

    reg [3:0]  bitcnt;
    reg [10:0] frame;             // 收满 11 位

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bitcnt <= 0; frame <= 0; data <= 0; valid <= 1'b0; err <= 1'b0;
        end else begin
            valid <= 1'b0;
            err   <= 1'b0;
            if (clk_fall) begin
                frame <= {d2, frame[10:1]};   // LSB 先，右移入
                if (bitcnt == 4'd10) begin
                    bitcnt <= 0;
                    // 此刻 {d2,frame[10:1]} 为完整帧：bit0=start,1..8=data,9=parity,10=stop
                    begin : decode
                        reg [10:0] f;
                        reg        par_ok, start_ok, stop_ok;
                        f = {d2, frame[10:1]};
                        start_ok = (f[0] == 1'b0);
                        stop_ok  = (f[10] == 1'b1);
                        par_ok   = (^f[8:1] ^ f[9]) == 1'b1;   // 奇校验：数据8位与校验位异或为1
                        data  <= f[8:1];
                        valid <= start_ok & stop_ok & par_ok;
                        err   <= ~(start_ok & stop_ok & par_ok);
                    end
                end else bitcnt <= bitcnt + 4'd1;
            end
        end
    end
endmodule
