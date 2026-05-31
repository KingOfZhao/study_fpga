`timescale 1ns/1ps
module comparator4_tb;
    reg  [3:0] a, b;
    wire gt, eq, lt;
    integer errors = 0;
    integer i, j;

    comparator4 dut (.a(a), .b(b), .gt(gt), .eq(eq), .lt(lt));

    initial begin
        $dumpfile("comparator4_tb.vcd");
        $dumpvars(0, comparator4_tb);
        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0]; b = j[3:0]; #1;
                if (gt !== (a > b) || eq !== (a == b) || lt !== (a < b) ||
                    (gt + eq + lt) !== 1) begin
                    errors = errors + 1;
                    $display("  MISMATCH a=%0d b=%0d gt=%b eq=%b lt=%b", a, b, gt, eq, lt);
                end
            end
        if (errors == 0) $display("[PASS] comparator4: 256 组比较全部正确且互斥");
        else             $display("[FAIL] comparator4: %0d 处错误", errors);
        $finish;
    end
endmodule
