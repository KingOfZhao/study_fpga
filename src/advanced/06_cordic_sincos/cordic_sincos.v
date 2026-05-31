// CORDIC（旋转模式）计算 sin/cos：定点 Q1.14（scale=16384）。
// 输入 angle 为弧度*16384（收敛范围约 ±1.74 rad）；start 后 ITER 拍输出 done。
`timescale 1ns/1ps

module cordic_sincos #(
    parameter integer W    = 16,
    parameter integer ITER = 15
) (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire signed [W-1:0]   angle,
    output reg  signed [W-1:0]   cos_o,
    output reg  signed [W-1:0]   sin_o,
    output reg                   done
);
    localparam signed [W-1:0] K = 16'd9949;   // 0.60725 * 16384
    localparam [4:0] LAST = ITER[4:0] - 5'd1;

    reg signed [W-1:0] atant [0:ITER-1];
    initial begin
        atant[0]=16'd12868; atant[1]=16'd7596; atant[2]=16'd4014;
        atant[3]=16'd2037;  atant[4]=16'd1023; atant[5]=16'd512;
        atant[6]=16'd256;   atant[7]=16'd128;  atant[8]=16'd64;
        atant[9]=16'd32;    atant[10]=16'd16;  atant[11]=16'd8;
        atant[12]=16'd4;    atant[13]=16'd2;   atant[14]=16'd1;
    end

    reg signed [W+1:0] x, y;
    reg signed [W-1:0] z;
    reg [4:0]          i;
    reg                busy;

    wire signed [W+1:0] xsh = x >>> i;
    wire signed [W+1:0] ysh = y >>> i;
    wire dir = (z >= 0);
    wire signed [W+1:0] xn = dir ? (x - ysh) : (x + ysh);
    wire signed [W+1:0] yn = dir ? (y + xsh) : (y - xsh);
    wire signed [W-1:0] zn = dir ? (z - atant[i[3:0]]) : (z + atant[i[3:0]]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0; y <= 0; z <= 0; i <= 0; busy <= 0; done <= 0;
            cos_o <= 0; sin_o <= 0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                x <= {{2{K[W-1]}}, K};
                y <= 0;
                z <= angle;
                i <= 0;
                busy <= 1'b1;
            end else if (busy) begin
                x <= xn;
                y <= yn;
                z <= zn;
                i <= i + 5'd1;
                if (i == LAST) begin
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    cos_o <= xn[W-1:0];
                    sin_o <= yn[W-1:0];
                end
            end
        end
    end
endmodule
