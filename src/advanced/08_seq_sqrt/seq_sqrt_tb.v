`timescale 1ns/1ps
module seq_sqrt_tb;
    localparam W = 16;
    reg clk = 0, rst_n, start;
    reg  [W-1:0] num;
    wire [W/2-1:0] root;
    wire busy, done;
    integer errors = 0;
    integer n, exp;

    seq_sqrt #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .start(start), .num(num),
                           .root(root), .busy(busy), .done(done));
    always #5 clk = ~clk;

    function integer isqrt(input integer v);
        integer r;
        begin
            r = 0;
            while ((r+1)*(r+1) <= v) r = r + 1;
            isqrt = r;
        end
    endfunction

    task do_sqrt(input [W-1:0] v);
        begin
            num = v;
            @(negedge clk); start = 1; @(negedge clk); start = 0;
            wait (done); @(negedge clk);
            exp = isqrt(v);
            if (root !== exp[W/2-1:0]) begin
                errors = errors + 1;
                $display("  sqrt(%0d)=%0d 期望=%0d", v, root, exp);
            end
        end
    endtask

    initial begin
        $dumpfile("seq_sqrt_tb.vcd");
        $dumpvars(0, seq_sqrt_tb);
        rst_n = 0; start = 0; num = 0;
        @(negedge clk); rst_n = 1;
        do_sqrt(16'd0);
        do_sqrt(16'd1);
        do_sqrt(16'd15);
        do_sqrt(16'd16);
        do_sqrt(16'd100);
        do_sqrt(16'd255);
        do_sqrt(16'd1024);
        do_sqrt(16'd9999);
        do_sqrt(16'd65535);
        if (errors == 0) $display("[PASS] seq_sqrt: 多组整数平方根正确");
        else             $display("[FAIL] seq_sqrt: %0d 处错误", errors);
        $finish;
    end

    initial begin #200000; $display("[FAIL] seq_sqrt: 超时"); $finish; end
endmodule
