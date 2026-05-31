// 多位数码管扫描显示（时分复用）
// 三个数码管共用一组段线，靠快速轮流点亮 + 位选(an) 实现"同时显示"。
// 把 8 位 value 转成 BCD，再按 sel 轮流把某一位的段码送出。
`timescale 1ns/1ps

module seven_seg #(
    parameter SCAN_DIV = 4     // 每位点亮的时钟数（仿真用小值；上板用大值防闪烁）
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] value,
    output reg  [2:0] an,      // 位选（低有效），一次只点亮一位
    output wire [7:0] seg      // 段码（低有效）
);
    localparam integer  CW   = (SCAN_DIV <= 2) ? 1 : $clog2(SCAN_DIV);
    localparam [CW-1:0] LAST = (CW)'(SCAN_DIV - 1);

    wire [3:0] huns, tens, ones;
    bin2bcd u_bcd (.bin(value), .huns(huns), .tens(tens), .ones(ones));

    reg [CW-1:0] dcnt;
    reg [1:0]    sel;          // 0=个位 1=十位 2=百位

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dcnt <= {CW{1'b0}};
            sel  <= 2'd0;
        end else if (dcnt == LAST) begin
            dcnt <= {CW{1'b0}};
            sel  <= (sel == 2'd2) ? 2'd0 : (sel + 1'b1);
        end else begin
            dcnt <= dcnt + 1'b1;
        end
    end

    reg [3:0] cur_digit;
    always @(*) begin
        case (sel)
            2'd0: cur_digit = ones;
            2'd1: cur_digit = tens;
            2'd2: cur_digit = huns;
            default: cur_digit = ones;
        endcase
    end

    always @(*) begin
        case (sel)
            2'd0: an = 3'b110;   // 点亮个位
            2'd1: an = 3'b101;   // 点亮十位
            2'd2: an = 3'b011;   // 点亮百位
            default: an = 3'b111;
        endcase
    end

    seg7 u_seg (.digit(cur_digit), .seg(seg));
endmodule
