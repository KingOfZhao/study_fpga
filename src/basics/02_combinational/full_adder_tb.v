// full_adder 自校验 testbench —— 穷举全部 8 种输入组合
`timescale 1ns/1ps

module full_adder_tb;
    reg        a, b, cin;
    wire       sum, cout;
    integer    i, errors = 0;
    reg  [1:0] expected;   // 期望的 {cout,sum}

    full_adder dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    initial begin
        $dumpfile("full_adder_tb.vcd");
        $dumpvars(0, full_adder_tb);

        // 组合逻辑没有时钟，直接遍历 000..111
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #5;                          // 等待组合逻辑稳定
            expected = a + b + cin;      // 0..3，用 2 位表示
            if ({cout, sum} !== expected) begin
                errors = errors + 1;
                $display("[FAIL] a=%b b=%b cin=%b -> {cout,sum}=%b%b exp=%b",
                         a, b, cin, cout, sum, expected);
            end else begin
                $display("[ OK ] a=%b b=%b cin=%b -> cout=%b sum=%b", a, b, cin, cout, sum);
            end
        end

        if (errors == 0)
            $display("[PASS] full_adder: all 8 cases passed");
        else begin
            $display("[FAIL] full_adder: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
