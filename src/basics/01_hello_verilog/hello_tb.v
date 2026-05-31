// hello_counter 自校验 testbench
// 既生成波形（GTKWave 可看），又自动判定 PASS/FAIL（供 CI 使用）
// 注意：Icarus Verilog 的 $display 对中文支持不佳，控制台标签统一用 ASCII。
`timescale 1ns/1ps

module hello_tb;
    reg        clk = 0;
    reg        rst_n;
    wire [3:0] count;
    integer    errors = 0;

    // 实例化待测模块 (DUT = Device Under Test)
    hello_counter dut (
        .clk  (clk),
        .rst_n(rst_n),
        .count(count)
    );

    // 100MHz 时钟（周期 10ns）
    always #5 clk = ~clk;

    // 断言：对比实际值与期望值
    task check(input [3:0] got, input [3:0] exp, input [255:0] name);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("[FAIL] %0s: got=%0d exp=%0d @%0t", name, got, exp, $time);
            end else begin
                $display("[ OK ] %0s = %0d", name, got);
            end
        end
    endtask

    initial begin
        $dumpfile("hello_tb.vcd");
        $dumpvars(0, hello_tb);

        // 复位（低有效）
        rst_n = 1'b0;
        @(posedge clk); #1;
        check(count, 4'd0, "count after reset");

        // 释放复位，计数 5 拍：0->1->2->3->4->5
        rst_n = 1'b1;
        repeat (5) @(posedge clk); #1;
        check(count, 4'd5, "count after 5 clocks");

        // 再次复位
        rst_n = 1'b0;
        @(posedge clk); #1;
        check(count, 4'd0, "count after re-reset");

        // 计数 20 拍，验证 4 位回绕：20 % 16 = 4
        rst_n = 1'b1;
        repeat (20) @(posedge clk); #1;
        check(count, 4'd4, "wrap-around 20 -> 4");

        if (errors == 0)
            $display("[PASS] hello_counter: all assertions passed");
        else begin
            $display("[FAIL] hello_counter: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
