// 可配置 SPI 主机：支持全部 4 种模式(CPOL/CPHA)，全双工 8 位传输。
// CPOL 决定 sclk 空闲电平；CPHA 决定采样/移位发生在前沿还是后沿。
`timescale 1ns/1ps

module spi_master_modes #(
    parameter integer DIV = 4,   // 半个 sclk 周期 = DIV 个系统时钟
    parameter integer W   = 8
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        cpol,
    input  wire        cpha,
    input  wire        start,
    input  wire [W-1:0] tx,
    output reg  [W-1:0] rx,
    output reg         busy,
    output reg         done,
    output reg         sclk,
    output reg         cs_n,
    output wire        mosi,
    input  wire        miso
);
    localparam integer CW = (DIV <= 1) ? 1 : $clog2(DIV);
    localparam [CW-1:0] DIVMAX = DIV[CW-1:0] - 1'b1;
    localparam integer EDGES = 2*W;
    localparam [4:0]    LASTE = EDGES[4:0] - 5'd1;

    reg [W-1:0]  tx_sh;
    reg [CW-1:0] divc;
    reg [4:0]    e;        // 边沿计数 0..2W-1
    reg          running;

    assign mosi = tx_sh[W-1];

    // 当前边沿是否采样 / 移位
    wire e_even   = (e[0] == 1'b0);
    wire sample_now = cpha ? ~e_even : e_even;          // cpha0:偶(前沿)采样; cpha1:奇(后沿)采样
    wire shift_now  = cpha ? (e_even && (e != 0)) : ~e_even;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_sh<=0; rx<=0; divc<=0; e<=0; running<=0; busy<=0; done<=0;
            sclk<=1'b0; cs_n<=1'b1;
        end else begin
            done <= 1'b0;
            if (!running) begin
                sclk <= cpol;
                if (start) begin
                    tx_sh<=tx; rx<=0; divc<=0; e<=0; running<=1'b1; busy<=1'b1;
                    cs_n<=1'b0; sclk<=cpol;
                end
            end else begin
                if (divc == DIVMAX) begin
                    divc <= 0;
                    sclk <= ~sclk;                       // 产生第 e 个边沿
                    if (sample_now) rx <= {rx[W-2:0], miso};
                    if (shift_now)  tx_sh <= {tx_sh[W-2:0], 1'b0};
                    if (e == LASTE) begin
                        running<=1'b0; busy<=1'b0; done<=1'b1;
                        cs_n<=1'b1; sclk<=cpol;
                    end
                    e <= e + 5'd1;
                end else divc <= divc + 1'b1;
            end
        end
    end
endmodule
