// 桶形移位器：单周期任意移位量。mode: 0=逻辑左移 1=逻辑右移 2=循环左移 3=算术右移
`timescale 1ns/1ps

module barrel_shifter #(
    parameter integer W = 8
) (
    input  wire [W-1:0]         din,
    input  wire [$clog2(W)-1:0] amt,
    input  wire [1:0]           mode,
    output reg  [W-1:0]         dout
);
    localparam integer SW = $clog2(W);
    localparam [SW:0] WV = W[SW:0];
    wire [SW:0] rsh = WV - {1'b0, amt};   // 循环左移所需的右移量（位宽对齐，lint 干净）

    always @(*) begin
        case (mode)
            2'd0: dout = din << amt;
            2'd1: dout = din >> amt;
            2'd2: dout = (amt == 0) ? din : ((din << amt) | (din >> rsh));
            default: dout = $signed(din) >>> amt;  // 算术右移
        endcase
    end
endmodule
