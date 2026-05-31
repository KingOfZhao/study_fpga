`timescale 1ns/1ps
module traffic_pedestrian_tb;
    localparam DB_N=4, RED_TIME=20, GREEN_TIME=20, YELLOW_TIME=6, GREEN_MIN=4;
    localparam [2:0] L_RED=3'b100, L_GREEN=3'b010, L_YELLOW=3'b001;
    reg clk = 0, rst_n, ped_btn;
    wire [2:0] light;
    wire ped_req;
    integer errors = 0;
    integer g1, g2;
    reg ped_enable;

    traffic_pedestrian #(.DB_N(DB_N), .RED_TIME(RED_TIME), .GREEN_TIME(GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME), .GREEN_MIN(GREEN_MIN)) dut (
        .clk(clk), .rst_n(rst_n), .ped_btn(ped_btn), .light(light), .ped_req(ped_req));
    always #5 clk = ~clk;

    // 行人按钮注入：使能后，进入绿灯并保持 GREEN_MIN 拍后按一次
    integer j;
    initial begin
        ped_btn = 0;
        forever begin
            wait (ped_enable && light==L_GREEN);
            repeat (GREEN_MIN+1) @(negedge clk);
            ped_btn = 1; repeat (DB_N+5) @(negedge clk); ped_btn = 0;
            ped_enable = 0;
            wait (light != L_GREEN);
        end
    end

    // 统计一段绿灯持续拍数
    task measure_green(output integer d);
        begin
            @(negedge clk); wait (light==L_GREEN);
            d = 0;
            while (light==L_GREEN) begin d = d + 1; @(negedge clk); end
        end
    endtask

    initial begin
        $dumpfile("traffic_pedestrian_tb.vcd");
        $dumpvars(0, traffic_pedestrian_tb);
        rst_n=0; ped_enable=0;
        repeat (3) @(negedge clk); rst_n=1;
        // 正常绿灯（无行人）
        measure_green(g1);
        $display("  正常绿灯持续=%0d 拍 (期望=%0d)", g1, GREEN_TIME);
        if (g1 < GREEN_TIME-1 || g1 > GREEN_TIME+1) begin errors=errors+1; $display("  正常绿灯时长异常"); end
        // 行人请求 -> 绿灯应提前结束
        ped_enable = 1;
        measure_green(g2);
        $display("  行人请求绿灯持续=%0d 拍 (应明显短于 %0d)", g2, g1);
        if (g2 >= g1)        begin errors=errors+1; $display("  行人请求未缩短绿灯"); end
        if (g2 < GREEN_MIN)  begin errors=errors+1; $display("  绿灯短于最短保持 GREEN_MIN"); end
        if (errors==0) $display("[PASS] traffic_pedestrian: 正常配时正确，行人请求触发绿灯提前结束放行");
        else            $display("[FAIL] traffic_pedestrian: %0d 处错误", errors);
        $finish;
    end
    initial begin #500000; $display("[FAIL] traffic_pedestrian: 超时"); $finish; end
endmodule
