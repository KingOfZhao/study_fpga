// 7 段数码管译码器（共阳极，低电平点亮）
// 输入一个十进制数字 0..9，输出 8 位段码 {dp,g,f,e,d,c,b,a}。
// 非 0..9 的输入显示空白（全灭）。
`timescale 1ns/1ps

module seg7 (
    input  wire [3:0] digit,
    output reg  [7:0] seg     // 低有效；bit7=小数点(dp)
);
    always @(*) begin
        case (digit)
            4'd0: seg = 8'hC0;
            4'd1: seg = 8'hF9;
            4'd2: seg = 8'hA4;
            4'd3: seg = 8'hB0;
            4'd4: seg = 8'h99;
            4'd5: seg = 8'h92;
            4'd6: seg = 8'h82;
            4'd7: seg = 8'hF8;
            4'd8: seg = 8'h80;
            4'd9: seg = 8'h90;
            default: seg = 8'hFF;   // 空白
        endcase
    end
endmodule
