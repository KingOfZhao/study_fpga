`timescale 1ns/1ps
module stepper_drive_tb;
    reg clk = 0, rst_n, step, dir;
    wire [3:0] phase;
    integer errors = 0;
    integer i;
    reg [3:0] seq [0:3];

    stepper_drive dut (.clk(clk), .rst_n(rst_n), .step(step), .dir(dir), .phase(phase));
    always #5 clk = ~clk;

    task do_step;
        begin
            step = 1; @(negedge clk); step = 0; @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("stepper_drive_tb.vcd");
        $dumpvars(0, stepper_drive_tb);
        seq[0]=4'b0001; seq[1]=4'b0010; seq[2]=4'b0100; seq[3]=4'b1000;
        rst_n = 0; step = 0; dir = 1;
        @(negedge clk); rst_n = 1; @(negedge clk);
        if (phase !== seq[0]) begin errors=errors+1; $display("  初始 phase=%b", phase); end
        // 正转一圈半
        for (i = 1; i <= 6; i = i + 1) begin
            do_step;
            if (phase !== seq[i % 4]) begin
                errors = errors + 1; $display("  正转步%0d phase=%b 期望=%b", i, phase, seq[i%4]);
            end
        end
        // 反转
        dir = 0;
        for (i = 5; i >= 0; i = i - 1) begin
            do_step;
            if (phase !== seq[i % 4]) begin
                errors = errors + 1; $display("  反转 -> phase=%b 期望=%b", phase, seq[i%4]);
            end
        end
        if (errors == 0) $display("[PASS] stepper_drive: 全步序列正/反转正确");
        else             $display("[FAIL] stepper_drive: %0d 处错误", errors);
        $finish;
    end
endmodule
