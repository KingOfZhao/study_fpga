// 综合项目：采样滤波后串口上报 = fir_movavg + uart_tx。
// 每个输入样本经 N 点移动平均滤波，滤波结果通过 UART 发出一字节。
`timescale 1ns/1ps

module adc_movavg_uart #(
    parameter integer DW           = 8,
    parameter integer N            = 4,
    parameter integer CLKS_PER_BIT = 8
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          sample_valid,
    input  wire [DW-1:0] sample,
    output wire [DW-1:0] filtered,
    output wire          tx_serial,
    output wire          tx_active
);
    wire valid_out;
    wire [DW-1:0] y;
    reg        tx_dv;
    reg  [7:0] tx_byte;
    wire       tx_done;

    fir_movavg #(.DW(DW), .N(N)) u_fir (
        .clk(clk), .rst_n(rst_n), .valid_in(sample_valid), .x(sample),
        .valid_out(valid_out), .y(y));

    assign filtered = y;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst_n(rst_n), .tx_dv(tx_dv), .tx_byte(tx_byte),
        .tx_active(tx_active), .tx_serial(tx_serial), .tx_done(tx_done));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin tx_dv<=0; tx_byte<=0; end
        else begin
            tx_dv <= 1'b0;
            if (valid_out) begin tx_byte <= {{(8-DW){1'b0}}, y}; tx_dv <= 1'b1; end
        end
    end
endmodule
