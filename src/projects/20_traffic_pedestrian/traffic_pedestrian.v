// 综合项目：带行人请求的红绿灯 = debounce + 交通灯 FSM。
// 正常 红->绿->黄 循环；行人按钮(去抖后)在绿灯期间登记请求，
// 使当前绿灯提前结束并尽快切到红灯放行行人。
`timescale 1ns/1ps

module traffic_pedestrian #(
    parameter integer DB_N        = 4,
    parameter integer RED_TIME    = 20,
    parameter integer GREEN_TIME  = 20,
    parameter integer YELLOW_TIME = 6,
    parameter integer GREEN_MIN   = 4    // 行人请求后绿灯至少再保持的拍数
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ped_btn,           // 行人按钮(带抖动、异步)
    output reg  [2:0] light,             // {R,G,Y}: 100红 010绿 001黄
    output reg        ped_req            // 行人请求挂起中
);
    localparam [1:0] S_RED=2'd0, S_GREEN=2'd1, S_YELLOW=2'd2;
    localparam [2:0] L_RED=3'b100, L_GREEN=3'b010, L_YELLOW=3'b001;
    localparam [15:0] REDM   = RED_TIME[15:0]    - 16'd1;
    localparam [15:0] GRNM   = GREEN_TIME[15:0]  - 16'd1;
    localparam [15:0] YELM   = YELLOW_TIME[15:0] - 16'd1;
    localparam [15:0] GMINM  = GREEN_MIN[15:0]   - 16'd1;

    wire ped_rise;
    wire db_state, db_fall;
    debounce #(.N(DB_N)) u_db (
        .clk(clk), .rst_n(rst_n), .btn_in(ped_btn),
        .btn_state(db_state), .btn_rise(ped_rise), .btn_fall(db_fall));

    reg [1:0]  state;
    reg [15:0] tmr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state<=S_RED; tmr<=0; light<=L_RED; ped_req<=0;
        end else begin
            // 登记行人请求（仅绿灯时有意义）
            if (ped_rise) ped_req <= 1'b1;

            case (state)
                S_RED: begin
                    light <= L_RED;
                    if (tmr >= REDM) begin state<=S_GREEN; tmr<=0; ped_req<=1'b0; end
                    else tmr <= tmr + 1'b1;
                end
                S_GREEN: begin
                    light <= L_GREEN;
                    // 有行人请求且已满足最短绿灯 -> 提前转黄
                    if (ped_req && tmr >= GMINM) begin state<=S_YELLOW; tmr<=0; end
                    else if (tmr >= GRNM)        begin state<=S_YELLOW; tmr<=0; end
                    else tmr <= tmr + 1'b1;
                end
                S_YELLOW: begin
                    light <= L_YELLOW;
                    if (tmr >= YELM) begin state<=S_RED; tmr<=0; end
                    else tmr <= tmr + 1'b1;
                end
                default: state<=S_RED;
            endcase
        end
    end
endmodule
