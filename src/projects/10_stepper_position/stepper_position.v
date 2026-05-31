// 综合项目：步进电机定位 = 位置控制器 + stepper_drive。
// 给定目标步数 target，控制器产生 step 脉冲驱动步进电机，直至当前步数到达目标。
`timescale 1ns/1ps

module stepper_position #(
    parameter integer SW = 16
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          go,        // 单拍：开始移动到 target
    input  wire          dir,
    input  wire [SW-1:0] target,    // 目标步数
    output wire [3:0]    phase,
    output reg  [SW-1:0] cur,        // 已走步数
    output reg           busy
);
    reg        step;
    reg  [1:0] div;        // 降低步进速率
    reg        running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur<=0; busy<=0; step<=0; div<=0; running<=0;
        end else begin
            step <= 1'b0;
            if (go && !running) begin
                cur<=0; running<=1'b1; busy<=1'b1; div<=0;
            end else if (running) begin
                if (cur >= target) begin running<=1'b0; busy<=1'b0; end
                else begin
                    div <= div + 1'b1;
                    if (div == 2'd3) begin       // 每 4 拍走一步
                        step <= 1'b1;
                        cur  <= cur + 1'b1;
                    end
                end
            end
        end
    end

    stepper_drive u_drv (.clk(clk), .rst_n(rst_n), .step(step), .dir(dir), .phase(phase));
endmodule
