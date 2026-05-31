// 步进电机全步驱动：每个 step 脉冲推进一个相位，dir 控制方向。
// 4 相全步序列：0001 -> 0010 -> 0100 -> 1000 -> ...
`timescale 1ns/1ps

module stepper_drive (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       step,    // 单拍脉冲：推进一步
    input  wire       dir,     // 1=正转 0=反转
    output reg  [3:0] phase
);
    reg [1:0] idx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) idx <= 2'd0;
        else if (step) idx <= dir ? (idx + 2'd1) : (idx - 2'd1);
    end

    always @(*) begin
        case (idx)
            2'd0: phase = 4'b0001;
            2'd1: phase = 4'b0010;
            2'd2: phase = 4'b0100;
            default: phase = 4'b1000;
        endcase
    end
endmodule
