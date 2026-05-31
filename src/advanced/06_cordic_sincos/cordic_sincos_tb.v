`timescale 1ns/1ps
module cordic_sincos_tb;
    localparam W = 16;
    localparam real SCALE = 16384.0;
    reg clk = 0, rst_n, start;
    reg  signed [W-1:0] angle;
    wire signed [W-1:0] cos_o, sin_o;
    wire done;
    integer errors = 0;
    real rad, expc, exps;
    integer ec, es;

    cordic_sincos #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .start(start), .angle(angle),
                                .cos_o(cos_o), .sin_o(sin_o), .done(done));
    always #5 clk = ~clk;

    task run_angle(input real r);
        begin
            rad   = r;
            angle = $rtoi(r * SCALE);
            @(negedge clk); start = 1; @(negedge clk); start = 0;
            wait (done); @(negedge clk);
            expc = $cos(r) * SCALE;
            exps = $sin(r) * SCALE;
            ec = cos_o - $rtoi(expc);
            es = sin_o - $rtoi(exps);
            if (ec < 0) ec = -ec;
            if (es < 0) es = -es;
            if (ec > 120 || es > 120) begin
                errors = errors + 1;
                $display("  angle=%f cos=%0d(期望%0d) sin=%0d(期望%0d)", r, cos_o, $rtoi(expc), sin_o, $rtoi(exps));
            end
        end
    endtask

    initial begin
        $dumpfile("cordic_sincos_tb.vcd");
        $dumpvars(0, cordic_sincos_tb);
        rst_n = 0; start = 0; angle = 0;
        repeat (2) @(negedge clk); rst_n = 1;
        run_angle(0.0);
        run_angle(0.5);
        run_angle(1.0);
        run_angle(-0.8);
        run_angle(0.7853981634);   // pi/4
        run_angle(1.2);
        if (errors == 0) $display("[PASS] cordic_sincos: 多个角度 sin/cos 与参考一致(误差<120/16384)");
        else             $display("[FAIL] cordic_sincos: %0d 处错误", errors);
        $finish;
    end

    initial begin #200000; $display("[FAIL] cordic_sincos: 超时"); $finish; end
endmodule
