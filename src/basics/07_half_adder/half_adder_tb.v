`timescale 1ns/1ps
module half_adder_tb;
    reg a, b;
    wire sum, cout;
    integer errors = 0;
    integer i;

    half_adder dut (.a(a), .b(b), .sum(sum), .cout(cout));

    initial begin
        $dumpfile("half_adder_tb.vcd");
        $dumpvars(0, half_adder_tb);
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i[1:0];
            #1;
            if (sum !== (a ^ b) || cout !== (a & b)) begin
                errors = errors + 1;
                $display("  MISMATCH a=%b b=%b -> sum=%b cout=%b", a, b, sum, cout);
            end
            #1;
        end
        if (errors == 0) $display("[PASS] half_adder: 4 种输入组合全部正确");
        else             $display("[FAIL] half_adder: %0d 处错误", errors);
        $finish;
    end
endmodule
