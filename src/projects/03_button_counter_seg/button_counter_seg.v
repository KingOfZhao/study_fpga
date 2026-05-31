// 组合案例 03：按键消抖 + 计数 + 数码管显示
// 把三个已学过的"原子组件"串成一条真实数据通路：
//   去抖(debounce) → 计数器 → 二进制转 BCD(bin2bcd) → 7 段译码(seg7)
// 每按一次键，计数 +1（自动去抖，一次只 +1），并在 3 位数码管上显示十进制值。
`timescale 1ns/1ps

module button_counter_seg #(
    parameter DB_N = 4          // 去抖采样次数（仿真用小值；上板按时钟调大）
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       btn_in,    // 带抖动的按键（异步）
    output reg  [7:0] count,     // 当前计数 0..255
    output wire [7:0] seg_huns,  // 百位段码（低有效）
    output wire [7:0] seg_tens,  // 十位段码
    output wire [7:0] seg_ones   // 个位段码
);
    // —— 原子组件 1：按键去抖 + 边沿检测 ——
    wire btn_rise;
    wire btn_state_nc, btn_fall_nc;   // 本案例只用上升沿脉冲，其余引脚悬空
    debounce #(.N(DB_N)) u_db (
        .clk(clk), .rst_n(rst_n), .btn_in(btn_in),
        .btn_state(btn_state_nc), .btn_rise(btn_rise), .btn_fall(btn_fall_nc)
    );

    // —— 计数器：每个有效按下脉冲 +1 ——
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 8'd0;
        else if (btn_rise)
            count <= count + 1'b1;     // 8 位自动回绕
    end

    // —— 原子组件 2：二进制转 BCD ——
    wire [3:0] huns, tens, ones;
    bin2bcd u_b2b (
        .bin(count), .huns(huns), .tens(tens), .ones(ones)
    );

    // —— 原子组件 3：三个 7 段译码器（每位一个）——
    seg7 u_s_h (.digit(huns), .seg(seg_huns));
    seg7 u_s_t (.digit(tens), .seg(seg_tens));
    seg7 u_s_o (.digit(ones), .seg(seg_ones));
endmodule
