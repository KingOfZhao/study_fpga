// 带 FIFO 缓冲的 UART 发送器：写入字节进 FIFO，模块自动逐字节发出。
// 含 sfifo(同步FIFO) + uart_tx + 顶层调度。
`timescale 1ns/1ps

module sfifo #(
    parameter integer DW = 8,
    parameter integer AW = 4
) (
    input  wire          clk, rst_n,
    input  wire          wr,
    input  wire [DW-1:0] din,
    output wire          full,
    input  wire          rd,
    output wire [DW-1:0] dout,
    output wire          empty
);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    reg [AW:0]   wptr, rptr;
    assign empty = (wptr == rptr);
    assign full  = (wptr[AW] != rptr[AW]) && (wptr[AW-1:0] == rptr[AW-1:0]);
    assign dout  = mem[rptr[AW-1:0]];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin wptr <= 0; rptr <= 0; end
        else begin
            if (wr && !full) begin mem[wptr[AW-1:0]] <= din; wptr <= wptr + 1'b1; end
            if (rd && !empty) rptr <= rptr + 1'b1;
        end
    end
endmodule

module uart_tx #(
    parameter integer CLKS_PER_BIT = 8
) (
    input  wire       clk, rst_n,
    input  wire       tx_dv,
    input  wire [7:0] tx_byte,
    output reg        tx_active,
    output reg        tx_serial,
    output reg        tx_done
);
    localparam IDLE=0, START=1, DATA=2, STOP=3;
    localparam integer CW = $clog2(CLKS_PER_BIT);
    localparam [CW-1:0] LASTB = CLKS_PER_BIT[CW-1:0] - 1'b1;
    reg [1:0]  state;
    reg [CW-1:0] cnt;
    reg [2:0]  bidx;
    reg [7:0]  data;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state<=IDLE; tx_active<=0; tx_serial<=1; tx_done<=0; cnt<=0; bidx<=0; data<=0;
        end else begin
            tx_done <= 0;
            case (state)
                IDLE: begin
                    tx_serial<=1; tx_active<=0; cnt<=0; bidx<=0;
                    if (tx_dv) begin data<=tx_byte; tx_active<=1; state<=START; end
                end
                START: begin
                    tx_serial<=0;
                    if (cnt==LASTB) begin cnt<=0; state<=DATA; end
                    else cnt<=cnt+1'b1;
                end
                DATA: begin
                    tx_serial<=data[bidx];
                    if (cnt==LASTB) begin
                        cnt<=0;
                        if (bidx==3'd7) state<=STOP; else bidx<=bidx+1'b1;
                    end else cnt<=cnt+1'b1;
                end
                STOP: begin
                    tx_serial<=1;
                    if (cnt==LASTB) begin cnt<=0; tx_done<=1; tx_active<=0; state<=IDLE; end
                    else cnt<=cnt+1'b1;
                end
                default: state<=IDLE;
            endcase
        end
    end
endmodule

module uart_tx_fifo #(
    parameter integer CLKS_PER_BIT = 8,
    parameter integer AW = 4
) (
    input  wire       clk, rst_n,
    input  wire       wr,
    input  wire [7:0] din,
    output wire       full,
    output wire       tx_serial,
    output wire       tx_active
);
    wire        empty;
    wire [7:0]  dout;
    wire        tx_done_nc;
    reg         dv, rd;
    reg  [7:0]  byte_r;

    wire can = !empty && !tx_active && !dv;

    sfifo #(.DW(8), .AW(AW)) u_fifo (
        .clk(clk), .rst_n(rst_n), .wr(wr), .din(din), .full(full),
        .rd(rd), .dout(dout), .empty(empty));

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst_n(rst_n), .tx_dv(dv), .tx_byte(byte_r),
        .tx_active(tx_active), .tx_serial(tx_serial), .tx_done(tx_done_nc));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin dv<=0; rd<=0; byte_r<=0; end
        else begin
            dv <= 1'b0; rd <= 1'b0;
            if (can) begin byte_r <= dout; dv <= 1'b1; rd <= 1'b1; end
        end
    end
endmodule
