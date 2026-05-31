// Testbench for hello_counter
`timescale 1ns/1ps

module hello_tb;
    reg clk;
    reg rst_n;
    wire [3:0] count;

    // 实例化待测模块 (DUT)
    hello_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    // 生成 100MHz 时钟 (周期 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 激励与测试
    initial begin
        $dumpfile("hello_tb.vcd");
        $dumpvars(0, hello_tb);

        // 复位
        rst_n = 0;
        #20;
        rst_n = 1;

        // 运行 20 个时钟周期
        #200;

        // 再次复位验证
        rst_n = 0;
        #15;
        rst_n = 1;

        #100;
        $display("Simulation finished. Count = %d", count);
        $finish;
    end

    // 监控输出
    initial begin
        $monitor("Time=%0t | rst_n=%b | count=%d", $time, rst_n, count);
    end

endmodule
