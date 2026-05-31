`timescale 1ns/1ps
module lfsr_tb;
    reg clk = 0, rst_n, en;
    wire [7:0] state;
    integer errors = 0;
    integer i;
    reg seen_zero = 0;
    reg [7:0] first;

    lfsr dut (.clk(clk), .rst_n(rst_n), .en(en), .state(state));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("lfsr_tb.vcd");
        $dumpvars(0, lfsr_tb);
        rst_n = 0; en = 1; @(negedge clk); rst_n = 1; #1;
        first = state;
        // 最大长度 LFSR：255 拍后回到初值，且全程不出现 0x00
        for (i = 0; i < 255; i = i + 1) begin
            @(posedge clk); #1;
            if (state == 8'h00) seen_zero = 1;
        end
        if (seen_zero)        begin errors = errors + 1; $display("  出现了 0x00（非最大长度）"); end
        if (state !== first)  begin errors = errors + 1; $display("  255 拍后未回到初值 first=%h now=%h", first, state); end
        if (errors == 0) $display("[PASS] lfsr: 周期=255、无 0 态，伪随机序列正确");
        else             $display("[FAIL] lfsr: %0d 处错误", errors);
        $finish;
    end
endmodule
