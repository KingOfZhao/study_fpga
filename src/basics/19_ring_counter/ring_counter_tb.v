`timescale 1ns/1ps
module ring_counter_tb;
    localparam N = 4;
    reg clk = 0, rst_n;
    wire [N-1:0] q;
    integer errors = 0;
    integer i, ones;
    reg [N-1:0] expq;

    ring_counter #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .q(q));
    always #5 clk = ~clk;

    integer b;
    initial begin
        $dumpfile("ring_counter_tb.vcd");
        $dumpvars(0, ring_counter_tb);
        rst_n = 0; @(negedge clk); rst_n = 1;
        #1;
        expq = 4'b0001;
        if (q !== expq) begin errors = errors + 1; $display("  INIT q=%b", q); end
        for (i = 0; i < 12; i = i + 1) begin
            @(posedge clk); #1;
            expq = {expq[N-2:0], expq[N-1]};
            // 任意时刻只有一个 1
            ones = 0;
            for (b = 0; b < N; b = b + 1) ones = ones + q[b];
            if (q !== expq || ones != 1) begin
                errors = errors + 1;
                $display("  MISMATCH i=%0d q=%b exp=%b ones=%0d", i, q, expq, ones);
            end
        end
        if (errors == 0) $display("[PASS] ring_counter: 单 1 循环移位正确");
        else             $display("[FAIL] ring_counter: %0d 处错误", errors);
        $finish;
    end
endmodule
