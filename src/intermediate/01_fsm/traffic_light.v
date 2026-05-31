// 交通灯状态机（Moore 型 FSM）
// 三段式写法：状态寄存器 / 次态逻辑 / 输出逻辑，是工业界 FSM 的标准模板。
// 各灯持续时间用参数表示，仿真时可调小以便快速、确定性地验证。
`timescale 1ns/1ps

module traffic_light #(
    parameter RED_TIME    = 50,
    parameter GREEN_TIME  = 30,
    parameter YELLOW_TIME = 10
) (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [2:0] light  // {R,G,Y}: 100=红, 010=绿, 001=黄
);

    localparam [1:0]
        STATE_RED    = 2'b00,
        STATE_GREEN  = 2'b01,
        STATE_YELLOW = 2'b10;

    reg [1:0] state, next_state;
    reg [7:0] timer;  // 计时器

    // 1) 状态寄存器：同步更新当前状态，并维护计时器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_RED;
            timer <= 8'd0;
        end else begin
            state <= next_state;
            if (state == next_state)
                timer <= timer + 1'b1;  // 停留在同一状态：计时 +1
            else
                timer <= 8'd0;          // 状态切换：计时清零
        end
    end

    // 2) 次态逻辑：根据当前状态与计时决定下一个状态
    always @(*) begin
        next_state = state;
        case (state)
            STATE_RED:    if (timer >= RED_TIME    - 1) next_state = STATE_GREEN;
            STATE_GREEN:  if (timer >= GREEN_TIME  - 1) next_state = STATE_YELLOW;
            STATE_YELLOW: if (timer >= YELLOW_TIME - 1) next_state = STATE_RED;
            default:      next_state = STATE_RED;
        endcase
    end

    // 3) 输出逻辑（Moore：输出只取决于当前状态）
    always @(*) begin
        case (state)
            STATE_RED:    light = 3'b100;
            STATE_GREEN:  light = 3'b010;
            STATE_YELLOW: light = 3'b001;
            default:      light = 3'b100;
        endcase
    end

endmodule
