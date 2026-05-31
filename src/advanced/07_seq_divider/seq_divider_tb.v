`timescale 1ns/1ps
module seq_divider_tb;
    localparam W = 8;
    reg clk = 0, rst_n, start;
    reg  [W-1:0] dividend, divisor;
    wire [W-1:0] quot, rem;
    wire busy, done;
    integer errors = 0;
    integer a, b;

    seq_divider #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .start(start),
        .dividend(dividend), .divisor(divisor), .quot(quot), .rem(rem), .busy(busy), .done(done));
    always #5 clk = ~clk;

    task do_div(input [W-1:0] x, input [W-1:0] y);
        begin
            dividend = x; divisor = y;
            @(negedge clk); start = 1; @(negedge clk); start = 0;
            wait (done); @(negedge clk);
            if (quot !== (x / y) || rem !== (x % y)) begin
                errors = errors + 1;
                $display("  %0d/%0d -> q=%0d r=%0d 期望 q=%0d r=%0d", x, y, quot, rem, x/y, x%y);
            end
        end
    endtask

    initial begin
        $dumpfile("seq_divider_tb.vcd");
        $dumpvars(0, seq_divider_tb);
        rst_n = 0; start = 0; dividend = 0; divisor = 1;
        @(negedge clk); rst_n = 1;
        do_div(8'd200, 8'd7);
        do_div(8'd255, 8'd16);
        do_div(8'd100, 8'd10);
        do_div(8'd17, 8'd5);
        do_div(8'd0, 8'd3);
        do_div(8'd123, 8'd1);
        do_div(8'd45, 8'd45);
        if (errors == 0) $display("[PASS] seq_divider: 多组除法商/余数正确");
        else             $display("[FAIL] seq_divider: %0d 处错误", errors);
        $finish;
    end

    initial begin #200000; $display("[FAIL] seq_divider: 超时"); $finish; end
endmodule
