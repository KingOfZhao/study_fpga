// 自校验 testbench：闭环电机调速（编码器 + 测速 + P 控制 + PWM）
//
// 测试 1（方向）：用独立的 quad_decoder 实例，喂正/反两种正交序列，
//                 校验解码出的 dir 在正转/反转时相反。
// 测试 2（闭环收敛）：内置一个"被控对象"模型——编码器脉冲频率 ∝ 当前占空比 duty，
//                 于是实测转速 speed ≈ duty。闭环应自动把 duty 调到 speed≈target。
`timescale 1ns/1ps

module motor_speed_ctrl_tb;
    localparam integer DW   = 8;
    localparam integer SPDW = 9;
    localparam integer WIN  = 512;
    localparam integer KSH  = 2;
    localparam [DW-1:0] TARGET = 8'd40;
    localparam integer  TOL    = 4;

    reg clk = 0;
    reg rst_n;
    integer errors = 0;

    always #5 clk = ~clk;

    // ---------------- 测试 1：方向解码（独立实例） ----------------
    reg  t_a, t_b;
    wire t_tick, t_dir;
    reg  d_fwd, d_rev;

    quad_decoder u_qd_test (
        .clk(clk), .rst_n(rst_n), .a(t_a), .b(t_b),
        .tick(t_tick), .dir(t_dir)
    );

    task settle;  // 保持当前相位若干拍，让两级同步稳定
        begin repeat (4) @(negedge clk); end
    endtask

    task fwd_cycle;  // 正转一圈：00→01→11→10
        begin
            t_a=1'b0; t_b=1'b0; settle;
            t_a=1'b0; t_b=1'b1; settle;
            t_a=1'b1; t_b=1'b1; settle;
            t_a=1'b1; t_b=1'b0; settle;
        end
    endtask

    task rev_cycle;  // 反转一圈：00→10→11→01
        begin
            t_a=1'b0; t_b=1'b0; settle;
            t_a=1'b1; t_b=1'b0; settle;
            t_a=1'b1; t_b=1'b1; settle;
            t_a=1'b0; t_b=1'b1; settle;
        end
    endtask

    // ---------------- 测试 2：闭环 + 被控对象模型 ----------------
    wire [DW-1:0]   duty;
    wire [SPDW-1:0] speed;
    wire            dir, sample, pwm_out;

    // 被控对象：相位累加器，步进 ∝ duty → 编码器频率 ∝ duty → speed ≈ duty
    reg  [15:0] pacc;
    wire [1:0]  phase = pacc[9:8];
    wire [1:0]  gray  = phase ^ (phase >> 1);
    wire        enc_a = gray[1];
    wire        enc_b = gray[0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pacc <= 16'd0;
        else        pacc <= pacc + {8'b0, duty};
    end

    motor_speed_ctrl #(.DW(DW), .SPDW(SPDW), .WIN(WIN), .KSH(KSH)) dut (
        .clk(clk), .rst_n(rst_n),
        .enc_a(enc_a), .enc_b(enc_b),
        .target(TARGET),
        .duty(duty), .speed(speed), .dir(dir), .sample(sample), .pwm_out(pwm_out)
    );

    integer sample_cnt;
    integer diff;

    initial begin
        $dumpfile("motor_speed_ctrl_tb.vcd");
        $dumpvars(0, motor_speed_ctrl_tb);

        t_a = 0; t_b = 0;
        rst_n = 1'b0;
        repeat (6) @(negedge clk);
        rst_n = 1'b1;
        repeat (4) @(negedge clk);

        // —— 测试 1：方向 ——
        repeat (3) fwd_cycle;  d_fwd = t_dir;
        repeat (3) rev_cycle;  d_rev = t_dir;
        if (d_fwd === d_rev) begin
            errors = errors + 1;
            $display("[FAIL] 方向解码未区分正反转：fwd=%b rev=%b", d_fwd, d_rev);
        end else
            $display("  方向解码 OK：正转 dir=%b，反转 dir=%b", d_fwd, d_rev);

        // —— 测试 2：闭环收敛 ——
        // 复位被控对象与闭环，重新起步
        rst_n = 1'b0; repeat (6) @(negedge clk);
        rst_n = 1'b1;

        sample_cnt = 0;
        while (sample_cnt < 80) begin
            @(posedge clk);
            if (sample) sample_cnt = sample_cnt + 1;
        end

        // 收敛后实测转速应接近目标
        diff = $signed({1'b0, speed}) - $signed({1'b0, TARGET});
        if (diff < 0) diff = -diff;
        $display("  收敛结果：target=%0d, speed=%0d, duty=%0d, |err|=%0d",
                 TARGET, speed, duty, diff);
        if (diff > TOL) begin
            errors = errors + 1;
            $display("[FAIL] 闭环未收敛到目标（|err|=%0d > %0d）", diff, TOL);
        end
        if (duty == 8'd0) begin
            errors = errors + 1;
            $display("[FAIL] duty 仍为 0，闭环未起作用");
        end

        if (errors == 0)
            $display("[PASS] motor_speed_ctrl: 方向解码正确，闭环转速收敛到目标");
        else
            $display("[FAIL] motor_speed_ctrl: 共 %0d 处错误", errors);
        $finish;
    end

    initial begin
        #5_000_000;
        $display("[FAIL] 仿真超时");
        $finish;
    end
endmodule
