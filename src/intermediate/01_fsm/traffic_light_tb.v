// traffic_light 自校验 testbench
// 用较小的相位时长以便快速、确定性地验证状态顺序与停留周期数。
`timescale 1ns/1ps

module traffic_light_tb;
    localparam RED_T = 4, GREEN_T = 3, YELLOW_T = 2;

    reg        clk = 0;
    reg        rst_n;
    wire [2:0] light;
    integer    errors = 0;

    traffic_light #(
        .RED_TIME(RED_T), .GREEN_TIME(GREEN_T), .YELLOW_TIME(YELLOW_T)
    ) dut (.clk(clk), .rst_n(rst_n), .light(light));

    always #5 clk = ~clk;

    // 验证某个相位：连续 dur 个周期 light 应等于 color
    task verify_phase(input [2:0] color, input integer dur, input [255:0] name);
        integer k;
        begin
            for (k = 0; k < dur; k = k + 1) begin
                if (light !== color) begin
                    errors = errors + 1;
                    $display("[FAIL] %0s cycle %0d: light=%b exp=%b @%0t",
                             name, k, light, color, $time);
                end
                @(posedge clk); #1;
            end
        end
    endtask

    initial begin
        $dumpfile("traffic_light_tb.vcd");
        $dumpvars(0, traffic_light_tb);

        // 复位
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        @(negedge clk); rst_n = 1'b1;

        // 对齐到一个干净的相位起点：等到黄灯，再等到刚切换成红灯
        // 注意在 #1 后采样 light（避开 NBA 更新尚未生效的时钟沿瞬间）
        @(posedge clk); #1;
        while (light !== 3'b001) begin @(posedge clk); #1; end  // 等到黄灯
        while (light !== 3'b100) begin @(posedge clk); #1; end  // 等到切回红灯（红相位第 0 周期）

        // 验证两整轮 红->绿->黄 顺序与时长
        verify_phase(3'b100, RED_T,    "RED");
        verify_phase(3'b010, GREEN_T,  "GREEN");
        verify_phase(3'b001, YELLOW_T, "YELLOW");
        verify_phase(3'b100, RED_T,    "RED(2nd)");
        verify_phase(3'b010, GREEN_T,  "GREEN(2nd)");
        verify_phase(3'b001, YELLOW_T, "YELLOW(2nd)");

        if (errors == 0)
            $display("[PASS] traffic_light: sequence & timing correct");
        else begin
            $display("[FAIL] traffic_light: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
