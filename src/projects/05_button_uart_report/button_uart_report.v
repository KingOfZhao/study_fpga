// 综合项目：按键计数串口上报 = debounce + 计数器 + uart_tx。
// 每次去抖后的按下(上升沿)使计数 +1，并把新计数值通过 UART 发出一字节。
`timescale 1ns/1ps

module button_uart_report #(
    parameter integer DB_N         = 4,
    parameter integer CLKS_PER_BIT = 8
) (
    input  wire clk,
    input  wire rst_n,
    input  wire btn_in,
    output wire tx_serial,
    output wire tx_active,
    output reg [7:0] count
);
    wire btn_rise, btn_fall, btn_state;
    reg        tx_dv;
    reg  [7:0] tx_byte;
    wire       tx_done;

    debounce #(.N(DB_N)) u_db (
        .clk(clk), .rst_n(rst_n), .btn_in(btn_in),
        .btn_state(btn_state), .btn_rise(btn_rise), .btn_fall(btn_fall));

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst_n(rst_n), .tx_dv(tx_dv), .tx_byte(tx_byte),
        .tx_active(tx_active), .tx_serial(tx_serial), .tx_done(tx_done));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin count<=0; tx_dv<=0; tx_byte<=0; end
        else begin
            tx_dv <= 1'b0;
            if (btn_rise) begin
                count   <= count + 1'b1;
                tx_byte <= count + 1'b1;     // 上报新计数
                tx_dv   <= 1'b1;
            end
        end
    end
endmodule
