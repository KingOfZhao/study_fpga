// 两级触发器同步器：把异步输入安全带入本时钟域，降低亚稳态传播概率。
// 任何与 FPGA 时钟异步的单 bit 输入（按键、enc_a/b、rx_serial、sda_i…）上板前都应先过它。
`timescale 1ns/1ps
module synchronizer #(
    parameter STAGES = 2,
    parameter INIT   = 1'b0
)(
    input  wire clk,
    input  wire rst_n,
    input  wire async_in,
    output wire sync_out
);
    reg [STAGES-1:0] q;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= {STAGES{INIT}};
        else        q <= {q[STAGES-2:0], async_in};
    end
    assign sync_out = q[STAGES-1];
endmodule
