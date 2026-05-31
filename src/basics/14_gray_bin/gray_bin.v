// 二进制 <-> 格雷码互转（组合）
// bin2gray: g = b ^ (b>>1)
// gray2bin: b[i] = ^(g >> i)   用前缀异或实现
`timescale 1ns/1ps

module gray_bin #(
    parameter integer W = 4
) (
    input  wire [W-1:0] bin_in,
    output wire [W-1:0] gray,
    input  wire [W-1:0] gray_in,
    output reg  [W-1:0] bin_out
);
    assign gray = bin_in ^ (bin_in >> 1);

    integer i;
    always @(*) begin
        bin_out[W-1] = gray_in[W-1];
        for (i = W-2; i >= 0; i = i - 1)
            bin_out[i] = bin_out[i+1] ^ gray_in[i];
    end
endmodule
