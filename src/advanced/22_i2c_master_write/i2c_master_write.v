// I2C 主机（多字节写）：START → 7位地址+写位 → ACK → 连续写 NBYTES 个字节(每个等 ACK) → STOP。
// SDA 开漏：sda_oe=1 拉低，0 释放(总线上拉为高)。SCL/SDA 输出寄存器化避免毛刺。
`timescale 1ns/1ps

module i2c_master_write #(
    parameter integer DIV    = 4,
    parameter integer NBYTES = 3
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start,
    input  wire [6:0]           dev_addr,
    input  wire [NBYTES*8-1:0]  wdata,     // 待写字节(低位字节先发)
    output reg                  done,
    output reg                  ack_err,
    output reg                  scl,
    output reg                  sda_oe,
    input  wire                 sda_i
);
    localparam [2:0] IDLE=0, START=1, ADDR=2, AACK=3, DATA=4, DACK=5, STOP=6, DONE=7;
    localparam integer   DCW   = (DIV <= 1) ? 1 : $clog2(DIV);
    localparam [DCW-1:0] DLAST = DIV[DCW-1:0] - 1'b1;
    localparam integer   BW    = $clog2(NBYTES) + 1;
    localparam [BW-1:0]  LASTBYTE = NBYTES[BW-1:0] - 1'b1;

    reg [DCW-1:0] dc;
    wire q_en = (dc == DLAST);

    reg [2:0]  state;
    reg [1:0]  ph;
    reg [3:0]  bcnt;
    reg [BW-1:0] byteidx;
    reg [7:0]  sh;
    reg        ackbit;

    wire bit_out = sh[7];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) dc <= 0;
        else        dc <= q_en ? {DCW{1'b0}} : (dc + 1'b1);
    end

    reg scl_c, sda_oe_c;
    always @(*) begin
        scl_c = 1'b1; sda_oe_c = 1'b0;
        case (state)
            IDLE:  begin scl_c=1'b1; sda_oe_c=1'b0; end
            START: begin scl_c=1'b1; sda_oe_c=1'b1; end
            ADDR:  begin scl_c=(ph==2'd1)||(ph==2'd2); sda_oe_c=(bit_out==1'b0); end
            DATA:  begin scl_c=(ph==2'd1)||(ph==2'd2); sda_oe_c=(bit_out==1'b0); end
            AACK:  begin scl_c=(ph==2'd1)||(ph==2'd2); sda_oe_c=1'b0; end
            DACK:  begin scl_c=(ph==2'd1)||(ph==2'd2); sda_oe_c=1'b0; end
            STOP:  begin scl_c=(ph!=2'd0); sda_oe_c=(ph<=2'd1); end
            DONE:  begin scl_c=1'b1; sda_oe_c=1'b0; end
            default: begin scl_c=1'b1; sda_oe_c=1'b0; end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin scl<=1'b1; sda_oe<=1'b0; end
        else begin scl<=scl_c; sda_oe<=sda_oe_c; end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state<=IDLE; ph<=0; bcnt<=0; byteidx<=0; sh<=0; ackbit<=1'b1;
            done<=1'b0; ack_err<=1'b0;
        end else begin
            done <= 1'b0;
            if (state == IDLE) begin
                if (start) begin
                    sh <= {dev_addr, 1'b0};   // 写位=0
                    bcnt<=0; ph<=0; byteidx<=0; ack_err<=1'b0;
                    state<=START;
                end
            end else if (q_en) begin
                if ((state==AACK || state==DACK) && ph==2'd2)
                    ackbit <= sda_i;          // SCL 高采样从机 ACK

                if (ph == 2'd3) begin
                    ph <= 2'd0;
                    case (state)
                        START: begin state<=ADDR; bcnt<=0; end
                        ADDR: begin
                            sh <= {sh[6:0], 1'b0};
                            if (bcnt==4'd7) state<=AACK; else bcnt<=bcnt+1'b1;
                        end
                        AACK: begin
                            if (ackbit) ack_err<=1'b1;
                            sh <= wdata[0 +: 8];     // 装载第 0 字节
                            byteidx <= 0; bcnt<=0; state<=DATA;
                        end
                        DATA: begin
                            sh <= {sh[6:0], 1'b0};
                            if (bcnt==4'd7) state<=DACK; else bcnt<=bcnt+1'b1;
                        end
                        DACK: begin
                            if (ackbit) ack_err<=1'b1;
                            if (byteidx == LASTBYTE) state<=STOP;
                            else begin
                                byteidx <= byteidx + 1'b1;
                                sh <= wdata[(byteidx+1)*8 +: 8];
                                bcnt<=0; state<=DATA;
                            end
                        end
                        STOP: begin state<=DONE; done<=1'b1; end
                        DONE: state<=IDLE;
                        default: state<=IDLE;
                    endcase
                end else ph <= ph + 1'b1;
            end
        end
    end
endmodule
