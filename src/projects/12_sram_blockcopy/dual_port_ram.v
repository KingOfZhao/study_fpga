// 简单双口 RAM：一个写端口 + 一个独立读端口（同一时钟），读为同步输出
`timescale 1ns/1ps

module dual_port_ram #(
    parameter integer W  = 8,
    parameter integer AW = 4
) (
    input  wire          clk,
    // 写端口
    input  wire          we,
    input  wire [AW-1:0] waddr,
    input  wire [W-1:0]  wdata,
    // 读端口
    input  wire [AW-1:0] raddr,
    output reg  [W-1:0]  rdata
);
    localparam integer DEPTH = (1 << AW);
    reg [W-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) mem[waddr] <= wdata;
        rdata <= mem[raddr];        // 同步读（1 拍延迟）
    end
endmodule
