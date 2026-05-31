// 综合项目：片上 RAM 自检（写-读回比对）= dual_port_ram + 测试 FSM。
// 向 RAM 全部地址写入 pattern(addr)=addr^0xA5，再逐个读回比对，输出 done/ok。
`timescale 1ns/1ps

module sram_blockcopy #(
    parameter integer W  = 8,
    parameter integer AW = 4
) (
    input  wire clk,
    input  wire rst_n,
    input  wire go,
    output reg  done,
    output reg  ok
);
    localparam integer DEPTH = (1<<AW);
    localparam [AW:0]  LASTI = DEPTH[AW:0] - 1'b1;

    reg  [AW-1:0] waddr, raddr;
    reg  [W-1:0]  wdata;
    reg           we;
    wire [W-1:0]  rdata;
    reg  [AW:0]   i;
    reg  [2:0]    st;

    function [W-1:0] pat(input [AW-1:0] a);
        pat = {{(W-AW){1'b0}}, a} ^ 8'hA5;
    endfunction

    dual_port_ram #(.W(W), .AW(AW)) u_ram (
        .clk(clk), .we(we), .waddr(waddr), .wdata(wdata),
        .raddr(raddr), .rdata(rdata));

    localparam IDLE=0, WR=1, RD_SET=2, RD_WAIT=3, RD_CHK=4, FIN=5;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            we<=0; waddr<=0; wdata<=0; raddr<=0; i<=0; st<=IDLE; done<=0; ok<=0;
        end else begin
            we<=1'b0; done<=1'b0;
            case (st)
                IDLE: if (go) begin i<=0; ok<=1'b1; st<=WR; end
                WR: begin
                    we<=1'b1; waddr<=i[AW-1:0]; wdata<=pat(i[AW-1:0]);
                    if (i == LASTI) begin i<=0; st<=RD_SET; end
                    else i<=i+1'b1;
                end
                RD_SET: begin raddr<=i[AW-1:0]; st<=RD_WAIT; end
                RD_WAIT: st<=RD_CHK;
                RD_CHK: begin
                    if (rdata !== pat(i[AW-1:0])) ok<=1'b0;
                    if (i == LASTI) st<=FIN;
                    else begin i<=i+1'b1; st<=RD_SET; end
                end
                FIN: begin done<=1'b1; st<=IDLE; end
                default: st<=IDLE;
            endcase
        end
    end
endmodule
