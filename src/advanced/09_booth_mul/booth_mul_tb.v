`timescale 1ns/1ps
module booth_mul_tb;
    localparam W = 8;
    reg clk = 0, rst_n, start;
    reg  signed [W-1:0] a, b;
    wire signed [2*W-1:0] product;
    wire busy, done;
    integer errors = 0;
    integer i;
    reg signed [2*W-1:0] expp;

    booth_mul #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b),
                            .product(product), .busy(busy), .done(done));
    always #5 clk = ~clk;

    task do_mul(input signed [W-1:0] x, input signed [W-1:0] y);
        begin
            a = x; b = y;
            @(negedge clk); start = 1; @(negedge clk); start = 0;
            wait (done); @(negedge clk);
            expp = x * y;
            if (product !== expp) begin
                errors = errors + 1;
                $display("  %0d * %0d = %0d 期望 %0d", x, y, product, expp);
            end
        end
    endtask

    initial begin
        $dumpfile("booth_mul_tb.vcd");
        $dumpvars(0, booth_mul_tb);
        rst_n = 0; start = 0; a = 0; b = 0;
        @(negedge clk); rst_n = 1;
        do_mul(8'sd7,   8'sd9);
        do_mul(-8'sd7,  8'sd9);
        do_mul(8'sd7,  -8'sd9);
        do_mul(-8'sd7, -8'sd9);
        do_mul(8'sd127, 8'sd127);
        do_mul(-8'sd128, 8'sd127);
        do_mul(-8'sd128,-8'sd128);
        do_mul(8'sd0,   8'sd55);
        for (i = 0; i < 8; i = i + 1)
            do_mul($random, $random);
        if (errors == 0) $display("[PASS] booth_mul: 多组有符号乘积正确（含随机用例）");
        else             $display("[FAIL] booth_mul: %0d 处错误", errors);
        $finish;
    end

    initial begin #300000; $display("[FAIL] booth_mul: 超时"); $finish; end
endmodule
