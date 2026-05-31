// 可编程倒计时定时器：load 装载初值，start 后每个 tick 递减，到 0 输出 done 脉冲
`timescale 1ns/1ps

module prog_timer #(
    parameter integer W = 16
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         load,
    input  wire [W-1:0] load_val,
    input  wire         start,
    input  wire         tick,       // 计数节拍
    output reg  [W-1:0] cnt,
    output reg          running,
    output reg          done
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; running <= 1'b0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (load) begin
                cnt <= load_val;
                running <= 1'b0;
            end else if (start) begin
                running <= 1'b1;
            end else if (running && tick) begin
                if (cnt <= 1) begin
                    cnt     <= 0;
                    running <= 1'b0;
                    done    <= 1'b1;
                end else cnt <= cnt - 1'b1;
            end
        end
    end
endmodule
