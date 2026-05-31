// 交通灯状态机（Moore 型 FSM）
module traffic_light (
    input wire clk,
    input wire rst_n,
    output reg [2:0] light  // RGY: 100=Red, 010=Green, 001=Yellow
);

    localparam [1:0]
        STATE_RED    = 2'b00,
        STATE_GREEN  = 2'b01,
        STATE_YELLOW = 2'b10;

    reg [1:0] state, next_state;
    reg [5:0] timer;  // 计时器

    // 状态寄存器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_RED;
            timer <= 6'd0;
        end else begin
            state <= next_state;
            if (state == next_state)
                timer <= timer + 1'b1;
            else
                timer <= 6'd0;
        end
    end

    // 次态逻辑
    always @(*) begin
        next_state = state;
        case (state)
            STATE_RED:    if (timer >= 6'd50) next_state = STATE_GREEN;
            STATE_GREEN:  if (timer >= 6'd30) next_state = STATE_YELLOW;
            STATE_YELLOW: if (timer >= 6'd10) next_state = STATE_RED;
            default: next_state = STATE_RED;
        endcase
    end

    // 输出逻辑 (Moore)
    always @(*) begin
        case (state)
            STATE_RED:    light = 3'b100;
            STATE_GREEN:  light = 3'b010;
            STATE_YELLOW: light = 3'b001;
            default:      light = 3'b100;
        endcase
    end

endmodule
