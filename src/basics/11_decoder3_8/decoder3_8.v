// 3:8 译码器：把 3 位地址译成 one-hot；en=0 时输出全 0
`timescale 1ns/1ps

module decoder3_8 (
    input  wire       en,
    input  wire [2:0] addr,
    output reg  [7:0] y
);
    always @(*) begin
        if (!en) y = 8'd0;
        else     y = (8'd1 << addr);
    end
endmodule
