`timescale 1ns/1ps
module tff_tb;
    reg clk = 0, rst_n, t;
    wire q;
    integer errors = 0;
    reg model = 0;

    tff dut (.clk(clk), .rst_n(rst_n), .t(t), .q(q));
    always #5 clk = ~clk;

    integer i;
    initial begin
        $dumpfile("tff_tb.vcd");
        $dumpvars(0, tff_tb);
        rst_n = 0; t = 0; model = 0;
        @(negedge clk); rst_n = 1;
        for (i = 0; i < 20; i = i + 1) begin
            t = $random;
            @(posedge clk);
            if (t) model = ~model;
            #1;
            if (q !== model) begin
                errors = errors + 1;
                $display("  MISMATCH i=%0d t=%b q=%b model=%b", i, t, q, model);
            end
        end
        if (errors == 0) $display("[PASS] tff: 翻转/保持行为正确");
        else             $display("[FAIL] tff: %0d 处错误", errors);
        $finish;
    end
endmodule
