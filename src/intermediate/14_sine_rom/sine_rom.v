// 正弦查找表 ROM：上电用 $sin 预计算一个周期，地址扫描即输出正弦波（DDS/波形发生的基础）
`timescale 1ns/1ps

module sine_rom #(
    parameter integer AW = 6,    // 64 点
    parameter integer DW = 8     // 8 位幅度
) (
    input  wire          clk,
    input  wire [AW-1:0] addr,
    output reg  [DW-1:0] data
);
    localparam integer DEPTH = (1 << AW);
    localparam real     PI    = 3.14159265358979;
    reg [DW-1:0] rom [0:DEPTH-1];

    integer i, v;
    real    s;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            s = $sin(2.0 * PI * i / DEPTH);
            v = $rtoi((s + 1.0) * ((1 << DW) - 1) / 2.0 + 0.5);
            rom[i] = v[DW-1:0];
        end
    end

    always @(posedge clk) data <= rom[addr];
endmodule
