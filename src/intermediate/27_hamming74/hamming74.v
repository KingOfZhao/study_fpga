// 汉明码 (7,4)：4 位数据 -> 7 位码字，解码可纠正任意 1 位错误。
// 码位(1-indexed): c1=p1 c2=p2 c3=d1 c4=p4 c5=d2 c6=d3 c7=d4
// data 映射: data[0]=d1 data[1]=d2 data[2]=d3 data[3]=d4
`timescale 1ns/1ps

module hamming74 (
    input  wire [3:0] data,        // 待编码数据
    output wire [6:0] code,        // 编码输出（c1..c7 放在 [0]..[6]）
    input  wire [6:0] rx,          // 待解码接收码字
    output wire [3:0] dec_data,    // 纠错后数据
    output wire [2:0] syndrome,    // 校验子(=出错位置, 0 表示无错)
    output wire       corrected    // 检测到并纠正了 1 位错误
);
    wire d1 = data[0], d2 = data[1], d3 = data[2], d4 = data[3];
    wire p1 = d1 ^ d2 ^ d4;
    wire p2 = d1 ^ d3 ^ d4;
    wire p4 = d2 ^ d3 ^ d4;
    // code[i] 对应码位 (i+1)
    assign code = {d4, d3, d2, p4, d1, p2, p1};

    // 解码：rx[i] 是码位 (i+1)
    wire s1 = rx[0] ^ rx[2] ^ rx[4] ^ rx[6];   // 位置 1,3,5,7
    wire s2 = rx[1] ^ rx[2] ^ rx[5] ^ rx[6];   // 位置 2,3,6,7
    wire s4 = rx[3] ^ rx[4] ^ rx[5] ^ rx[6];   // 位置 4,5,6,7
    assign syndrome = {s4, s2, s1};            // = 出错的码位(1-indexed)

    assign corrected = (syndrome != 3'd0);
    // 纠正：翻转出错位
    wire [6:0] fixed = corrected ? (rx ^ (7'd1 << (syndrome - 3'd1))) : rx;
    assign dec_data = {fixed[6], fixed[5], fixed[4], fixed[2]};  // d4 d3 d2 d1
endmodule
