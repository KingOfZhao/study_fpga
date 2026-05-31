// CRC-16/CCITT-FALSE：多项式 0x1021，初值 0xFFFF，bit-serial(MSB 先)。
// 对 "123456789" 的校验值应为 0x29B1。
`timescale 1ns/1ps

module crc16 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clr,
    input  wire        bit_in,
    input  wire        bit_valid,
    output reg  [15:0] crc
);
    wire fb = crc[15] ^ bit_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      crc <= 16'hFFFF;
        else if (clr)    crc <= 16'hFFFF;
        else if (bit_valid)
            crc <= {crc[14:0], 1'b0} ^ (fb ? 16'h1021 : 16'h0000);
    end
endmodule
