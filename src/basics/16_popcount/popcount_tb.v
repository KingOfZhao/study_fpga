`timescale 1ns/1ps
module popcount_tb;
    localparam W = 8;
    reg  [W-1:0] din;
    wire [3:0]   count;
    integer errors = 0;
    integer i;

    popcount #(.W(W)) dut (.din(din), .count(count));

    initial begin
        $dumpfile("popcount_tb.vcd");
        $dumpvars(0, popcount_tb);
        for (i = 0; i < 256; i = i + 1) begin
            din = i[W-1:0];
            #1;
            if (count !== $countones(din)) begin
                errors = errors + 1;
                $display("  MISMATCH din=%b count=%0d exp=%0d", din, count, $countones(din));
            end
        end
        if (errors == 0) $display("[PASS] popcount: 256 种输入计数全部正确");
        else             $display("[FAIL] popcount: %0d 处错误", errors);
        $finish;
    end
endmodule
