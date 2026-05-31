// 曼彻斯特编码器：把 8 位数据(LSB 先)串行编码，每个数据位用 2 个 chip 表示
// 约定(G.E.Thomas)：bit=1 -> 高低(1,0)，bit=0 -> 低高(0,1)，即 chip = bit XOR phase
`timescale 1ns/1ps

module manchester_enc (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] data,
    output wire       tx,        // 串行 chip 输出（空闲为高）
    output reg        active,
    output reg        done
);
    reg [7:0] sh;
    reg [3:0] cnt;               // 0..15，共 16 个 chip

    assign tx = active ? (sh[cnt[3:1]] ^ cnt[0]) : 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active <= 1'b0; cnt <= 0; sh <= 0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!active) begin
                if (start) begin active <= 1'b1; cnt <= 0; sh <= data; end
            end else begin
                if (cnt == 4'd15) begin active <= 1'b0; done <= 1'b1; end
                else cnt <= cnt + 4'd1;
            end
        end
    end
endmodule
