// I2C 开漏三态顶层封装示例：仿真用 sda_oe/sda_i 两根线，上板需要真正的 inout + 三态。
// 这个 wrapper 展示如何把内部 oe/i 接到物理 inout 引脚（外部需 4.7k 上拉到 VCC）。
`timescale 1ns/1ps
module i2c_iobuf_top (
    input  wire scl_oe,      // 内核：SCL 拉低使能
    input  wire sda_oe,      // 内核：SDA 拉低使能（开漏，只拉低不拉高）
    output wire sda_i,       // 回读 SDA 实际电平给内核
    inout  wire scl,         // 物理 SCL 引脚
    inout  wire sda          // 物理 SDA 引脚
);
    // 开漏：oe=1 时拉低，否则高阻（由外部上拉拉高）
    assign scl   = scl_oe ? 1'b0 : 1'bz;
    assign sda   = sda_oe ? 1'b0 : 1'bz;
    assign sda_i = sda;      // 总线真实电平（含从机 ACK 时的拉低）
endmodule
