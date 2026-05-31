// debounce 自校验 testbench
// 先制造抖动再稳定到高电平（按下），随后抖动再稳定到低电平（松开）。
// 期望：恰好 1 次上升沿、1 次下降沿，且抖动期间不误触发。
`timescale 1ns/1ps

module debounce_tb;
    localparam N = 4;

    reg  clk = 1'b0;
    reg  rst_n;
    reg  btn_in;
    wire btn_state, btn_rise, btn_fall;

    integer rise_cnt = 0;
    integer fall_cnt = 0;
    integer errors   = 0;

    debounce #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .btn_in(btn_in),
        .btn_state(btn_state), .btn_rise(btn_rise), .btn_fall(btn_fall)
    );

    always #5 clk = ~clk;

    always @(posedge clk) if (rst_n) begin
        if (btn_rise) rise_cnt = rise_cnt + 1;
        if (btn_fall) fall_cnt = fall_cnt + 1;
    end

    initial begin
        $dumpfile("debounce_tb.vcd");
        $dumpvars(0, debounce_tb);
        btn_in = 1'b0;
        rst_n  = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        // —— 按下：先抖动几下，再稳定到高 ——
        btn_in = 1'b1; @(posedge clk);
        btn_in = 1'b0; @(posedge clk);
        btn_in = 1'b1; @(posedge clk);
        btn_in = 1'b0; @(posedge clk);
        btn_in = 1'b1;                       // 稳定到高
        repeat (N + 6) @(posedge clk);
        if (btn_state !== 1'b1) begin
            errors = errors + 1;
            $display("[FAIL] 稳定后 btn_state 应为 1，实际 %b", btn_state);
        end else $display("[ OK ] 按下已去抖，btn_state=1");

        // —— 松开：再抖动几下，稳定到低 ——
        btn_in = 1'b0; @(posedge clk);
        btn_in = 1'b1; @(posedge clk);
        btn_in = 1'b0;                       // 稳定到低
        repeat (N + 6) @(posedge clk);
        if (btn_state !== 1'b0) begin
            errors = errors + 1;
            $display("[FAIL] 稳定后 btn_state 应为 0，实际 %b", btn_state);
        end else $display("[ OK ] 松开已去抖，btn_state=0");

        if (rise_cnt !== 1) begin
            errors = errors + 1;
            $display("[FAIL] 上升沿脉冲数=%0d 期望=1", rise_cnt);
        end
        if (fall_cnt !== 1) begin
            errors = errors + 1;
            $display("[FAIL] 下降沿脉冲数=%0d 期望=1", fall_cnt);
        end

        if (errors == 0)
            $display("[PASS] debounce: 去抖正确，rise=1 fall=1");
        else begin
            $display("[FAIL] debounce: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
