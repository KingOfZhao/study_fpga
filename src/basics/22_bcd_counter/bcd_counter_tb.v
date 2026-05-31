`timescale 1ns/1ps
module bcd_counter_tb;
    reg clk = 0, rst_n, en;
    wire [3:0] bcd;
    wire carry;
    integer errors = 0;
    integer i, carries = 0;

    bcd_counter dut (.clk(clk), .rst_n(rst_n), .en(en), .bcd(bcd), .carry(carry));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("bcd_counter_tb.vcd");
        $dumpvars(0, bcd_counter_tb);
        rst_n = 0; en = 1; @(negedge clk); rst_n = 1;
        // 连续计数 25 拍，校验范围 0..9 且每 10 拍 1 次进位
        for (i = 0; i < 25; i = i + 1) begin
            #1;
            if (bcd > 4'd9) begin errors = errors + 1; $display("  RANGE bcd=%0d", bcd); end
            if (carry) begin
                carries = carries + 1;
                if (bcd !== 4'd9) begin errors = errors + 1; $display("  CARRY at bcd=%0d", bcd); end
            end
            @(posedge clk);
        end
        if (carries < 2) begin errors = errors + 1; $display("  too few carries=%0d", carries); end
        if (errors == 0) $display("[PASS] bcd_counter: 0..9 循环且进位正确（carry=%0d）", carries);
        else             $display("[FAIL] bcd_counter: %0d 处错误", errors);
        $finish;
    end
endmodule
