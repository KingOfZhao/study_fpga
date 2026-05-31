// 4x4 矩阵键盘扫描：逐行拉低(row)、读列(col)，定位按下的键。
// row/col 均低有效。key = row*4 + col，key_valid 在检测到按键时脉冲一拍。
`timescale 1ns/1ps

module keypad_scanner (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] col,        // 列输入（低有效，未按为全 1）
    output reg  [3:0] row,        // 行驱动（低有效，一次拉低一行）
    output reg  [3:0] key,        // 键码 0..15
    output reg        key_valid
);
    reg [1:0] rowsel;
    reg [1:0] colidx;
    reg       found;

    always @(*) begin
        found  = 1'b0;
        colidx = 2'd0;
        casez (~col)               // ~col：按下的列为 1
            4'b???1: begin found = 1'b1; colidx = 2'd0; end
            4'b??10: begin found = 1'b1; colidx = 2'd1; end
            4'b?100: begin found = 1'b1; colidx = 2'd2; end
            4'b1000: begin found = 1'b1; colidx = 2'd3; end
            default: begin found = 1'b0; colidx = 2'd0; end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rowsel <= 2'd0; row <= 4'b1110; key <= 4'd0; key_valid <= 1'b0;
        end else begin
            key_valid <= 1'b0;
            if (found) begin
                key       <= {rowsel, colidx};
                key_valid <= 1'b1;
            end
            rowsel <= rowsel + 2'd1;
            row    <= ~(4'b0001 << (rowsel + 2'd1));
        end
    end
endmodule
