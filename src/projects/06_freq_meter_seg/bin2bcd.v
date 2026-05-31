// 二进制转 BCD —— double dabble（移位加 3）算法，纯组合逻辑
// 把 8 位二进制 (0..255) 拆成百/十/个位三个 BCD 数字。
`timescale 1ns/1ps

module bin2bcd (
    input  wire [7:0] bin,
    output reg  [3:0] huns,   // 百位
    output reg  [3:0] tens,   // 十位
    output reg  [3:0] ones    // 个位
);
    integer    i;
    reg [19:0] shift;          // [19:8]=BCD(百/十/个) ，[7:0]=待移入的二进制

    always @(*) begin
        shift        = 20'd0;
        shift[7:0]   = bin;
        for (i = 0; i < 8; i = i + 1) begin
            // 移位前：任一 BCD 位 >=5 就 +3，保证移位后仍是合法 BCD
            if (shift[11:8]  >= 4'd5) shift[11:8]  = shift[11:8]  + 4'd3;
            if (shift[15:12] >= 4'd5) shift[15:12] = shift[15:12] + 4'd3;
            if (shift[19:16] >= 4'd5) shift[19:16] = shift[19:16] + 4'd3;
            shift = shift << 1;
        end
        huns = shift[19:16];
        tens = shift[15:12];
        ones = shift[11:8];
    end
endmodule
