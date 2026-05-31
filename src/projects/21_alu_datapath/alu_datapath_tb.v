`timescale 1ns/1ps
module alu_datapath_tb;
    reg clk = 0, rst_n, start;
    wire done;
    reg  [1:0] dbg_addr;
    wire [7:0] dbg_data;
    integer errors = 0;
    reg  [7:0] exp [0:3];

    alu_datapath dut (.clk(clk), .rst_n(rst_n), .start(start),
        .done(done), .dbg_addr(dbg_addr), .dbg_data(dbg_data));
    always #5 clk = ~clk;

    task check(input [1:0] idx, input [7:0] e);
        begin
            dbg_addr = idx; @(negedge clk);
            if (dbg_data !== e) begin errors=errors+1; $display("  r%0d=%0d 期望=%0d", idx, dbg_data, e); end
            else $display("  r%0d = %0d  正确", idx, dbg_data);
        end
    endtask

    initial begin
        $dumpfile("alu_datapath_tb.vcd");
        $dumpvars(0, alu_datapath_tb);
        exp[0]=8'd5; exp[1]=8'd3; exp[2]=8'd16; exp[3]=8'd2;
        rst_n=0; start=0; dbg_addr=0;
        repeat (3) @(negedge clk); rst_n=1;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait (done); @(negedge clk);
        $display("  微程序执行完毕，校验寄存器堆：");
        check(2'd0, exp[0]);
        check(2'd1, exp[1]);
        check(2'd2, exp[2]);
        check(2'd3, exp[3]);
        if (errors==0) $display("[PASS] alu_datapath: 微指令通路取指/ALU/写回，4 寄存器结果全部正确");
        else            $display("[FAIL] alu_datapath: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] alu_datapath: 超时"); $finish; end
endmodule
