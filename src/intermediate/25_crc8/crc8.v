// CRC-8 (SMBus)：多项式 0x07，初值 0x00，bit-serial(MSB 先)。
// 对 "123456789" 的校验值应为 0xF4。
`timescale 1ns/1ps

module crc8 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       clr,        // 清零 CRC（开始新消息）
    input  wire       bit_in,
    input  wire       bit_valid,
    output reg  [7:0] crc
);
    wire fb = crc[7] ^ bit_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      crc <= 8'h00;
        else if (clr)    crc <= 8'h00;
        else if (bit_valid)
            crc <= {crc[6:0], 1'b0} ^ (fb ? 8'h07 : 8'h00);
    end
endmodule
