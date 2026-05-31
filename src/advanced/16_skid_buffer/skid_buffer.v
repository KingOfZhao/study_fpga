// Skid Buffer：valid/ready 握手的流水寄存器，支持背压且不丢数、不产生组合环。
// 当下游 m_ready 拉低使输出停顿时，用 skid 寄存器吸收一拍输入。
`timescale 1ns/1ps

module skid_buffer #(
    parameter integer W = 8
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         s_valid,
    input  wire [W-1:0] s_data,
    output wire         s_ready,
    output wire         m_valid,
    output wire [W-1:0] m_data,
    input  wire         m_ready
);
    reg [W-1:0] out_data, skid_data;
    reg         out_valid, skid_valid;

    assign s_ready = ~skid_valid;     // skid 空时可接收
    assign m_valid = out_valid;
    assign m_data  = out_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_data<=0; skid_data<=0; out_valid<=0; skid_valid<=0;
        end else begin
            if (m_ready || !out_valid) begin
                // 输出寄存器可装新数据
                if (skid_valid) begin
                    out_data   <= skid_data;
                    out_valid  <= 1'b1;
                    skid_valid <= 1'b0;
                end else begin
                    out_data  <= s_data;
                    out_valid <= s_valid;
                end
            end else begin
                // 输出停顿：把来的数据存入 skid
                if (s_valid && s_ready) begin
                    skid_data  <= s_data;
                    skid_valid <= 1'b1;
                end
            end
        end
    end
endmodule
