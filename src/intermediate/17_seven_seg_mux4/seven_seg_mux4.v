// 4 位数码管动态扫描：分时点亮 4 个数位（共阳，段/位选均低有效）
// seg = {a,b,c,d,e,f,g} 低有效；an[i]=0 选中第 i 位
`timescale 1ns/1ps

module seven_seg_mux4 #(
    parameter integer REFRESH = 4   // 每位点亮 REFRESH 个时钟后切换
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] d0,
    input  wire [3:0] d1,
    input  wire [3:0] d2,
    input  wire [3:0] d3,
    output reg  [3:0] an,
    output reg  [6:0] seg
);
    localparam integer CW = $clog2(REFRESH);
    localparam [CW-1:0] MAXC = REFRESH[CW-1:0] - 1'b1;
    reg [CW-1:0] cnt;
    reg [1:0]    sel;
    reg [3:0]    digit;

    function [6:0] decode(input [3:0] v);
        case (v)
            4'd0: decode = 7'b1111110;
            4'd1: decode = 7'b0110000;
            4'd2: decode = 7'b1101101;
            4'd3: decode = 7'b1111001;
            4'd4: decode = 7'b0110011;
            4'd5: decode = 7'b1011011;
            4'd6: decode = 7'b1011111;
            4'd7: decode = 7'b1110000;
            4'd8: decode = 7'b1111111;
            4'd9: decode = 7'b1111011;
            default: decode = 7'b0000000;
        endcase
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; sel <= 0;
        end else if (cnt == MAXC) begin
            cnt <= 0; sel <= sel + 2'd1;
        end else cnt <= cnt + 1'b1;
    end

    always @(*) begin
        case (sel)
            2'd0: digit = d0;
            2'd1: digit = d1;
            2'd2: digit = d2;
            default: digit = d3;
        endcase
        an  = ~(4'd1 << sel);    // 选中位为 0
        seg = ~decode(digit);    // 段低有效
    end
endmodule
