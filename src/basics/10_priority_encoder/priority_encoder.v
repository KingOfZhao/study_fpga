// 8:3 优先编码器：输出最高位为 1 的索引；valid 指示是否有任一位为 1
`timescale 1ns/1ps

module priority_encoder (
    input  wire [7:0] req,
    output reg  [2:0] code,
    output reg        valid
);
    integer i;
    always @(*) begin
        code  = 3'd0;
        valid = 1'b0;
        for (i = 0; i < 8; i = i + 1) begin
            if (req[i]) begin
                code  = i[2:0];   // 循环到最高的置 1 位
                valid = 1'b1;
            end
        end
    end
endmodule
