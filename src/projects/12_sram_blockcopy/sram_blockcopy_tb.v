`timescale 1ns/1ps
module sram_blockcopy_tb;
    reg clk = 0, rst_n, go;
    wire done, ok;
    integer errors = 0;

    sram_blockcopy #(.W(8), .AW(4)) dut (
        .clk(clk), .rst_n(rst_n), .go(go), .done(done), .ok(ok));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sram_blockcopy_tb.vcd");
        $dumpvars(0, sram_blockcopy_tb);
        rst_n=0; go=0;
        repeat (2) @(negedge clk); rst_n=1;
        @(negedge clk); go=1; @(negedge clk); go=0;
        @(posedge done); #1;
        if (!ok) begin errors=errors+1; $display("  RAM 写-读回比对失败 ok=%b", ok); end
        else      $display("  16 个地址写入并读回比对全部一致");
        if (errors==0) $display("[PASS] sram_blockcopy: 双口 RAM 全地址写-读回自检通过");
        else            $display("[FAIL] sram_blockcopy: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] sram_blockcopy: 超时"); $finish; end
endmodule
