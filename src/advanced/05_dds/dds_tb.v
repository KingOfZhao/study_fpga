`timescale 1ns/1ps
module dds_tb;
    localparam PA = 12, AW = 6, DW = 8;
    reg clk = 0, rst_n, en;
    reg  [PA-1:0] fword;
    wire [DW-1:0] wave;
    integer errors = 0;
    integer i, v, k;
    real s;
    localparam real PI = 3.14159265358979;
    reg [DW-1:0] ref_rom [0:(1<<AW)-1];
    reg [PA-1:0] ph;

    dds #(.PA(PA), .AW(AW), .DW(DW)) dut (.clk(clk), .rst_n(rst_n), .en(en), .fword(fword), .wave(wave));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dds_tb.vcd");
        $dumpvars(0, dds_tb);
        for (i = 0; i < (1<<AW); i = i + 1) begin
            s = $sin(2.0 * PI * i / (1<<AW));
            v = $rtoi((s + 1.0) * ((1 << DW) - 1) / 2.0 + 0.5);
            ref_rom[i] = v[DW-1:0];
        end
        rst_n = 0; en = 0; fword = 0; ph = 0;
        @(negedge clk); rst_n = 1;
        fword = 12'd131;     // 任意频率字
        en = 1;
        for (k = 0; k < 200; k = k + 1) begin
            @(negedge clk);  #1;
            ph = ph + fword;   // DUT 在本周期上升沿已累加
            if (wave !== ref_rom[ph[PA-1:PA-AW]]) begin
                errors = errors + 1;
                if (errors < 5) $display("  k=%0d phase=%0d wave=%0d 期望=%0d", k, ph, wave, ref_rom[ph[PA-1:PA-AW]]);
            end
        end
        if (errors == 0) $display("[PASS] dds: 200 个样本与相位累加查表一致");
        else             $display("[FAIL] dds: %0d 处错误", errors);
        $finish;
    end
endmodule
