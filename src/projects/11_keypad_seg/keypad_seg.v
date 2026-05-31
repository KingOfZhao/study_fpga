// 综合项目：矩阵键盘 + 数码管 = keypad_scanner + seg7。
// 扫描到的按键码锁存后在数码管显示。
`timescale 1ns/1ps

module keypad_seg (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] col,
    output wire [3:0] row,
    output reg  [3:0] key_latched,
    output wire       key_valid,
    output wire [7:0] seg
);
    wire [3:0] key;

    keypad_scanner u_kp (
        .clk(clk), .rst_n(rst_n), .col(col), .row(row),
        .key(key), .key_valid(key_valid));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) key_latched <= 4'd0;
        else if (key_valid) key_latched <= key;
    end

    seg7 u_seg (.digit(key_latched), .seg(seg));
endmodule
