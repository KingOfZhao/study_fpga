`timescale 1ns/1ps
module spi_master_modes_tb;
    localparam DIV = 4, W = 8;
    reg clk = 0, rst_n, cpol, cpha, start;
    reg  [W-1:0] tx;
    wire [W-1:0] rx;
    wire busy, done, sclk, cs_n, mosi;
    integer errors = 0;
    integer m;

    spi_master_modes #(.DIV(DIV), .W(W)) dut (
        .clk(clk), .rst_n(rst_n), .cpol(cpol), .cpha(cpha), .start(start),
        .tx(tx), .rx(rx), .busy(busy), .done(done),
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .miso(mosi));  // 回环: miso=mosi
    always #5 clk = ~clk;

    task xfer(input p, input h, input [W-1:0] d);
        begin
            cpol=p; cpha=h; tx=d;
            @(negedge clk); start=1; @(negedge clk); start=0;
            wait (done); @(negedge clk);
            // 回环下全双工收到的应等于发出的
            if (rx !== d) begin
                errors=errors+1;
                $display("  CPOL=%0d CPHA=%0d tx=%h rx=%h", p, h, d, rx);
            end
            if (cs_n !== 1'b1 || sclk !== p) begin
                errors=errors+1;
                $display("  结束态异常 CPOL=%0d cs_n=%b sclk=%b", p, cs_n, sclk);
            end
        end
    endtask

    initial begin
        $dumpfile("spi_master_modes_tb.vcd");
        $dumpvars(0, spi_master_modes_tb);
        rst_n=0; cpol=0; cpha=0; start=0; tx=0;
        repeat (2) @(negedge clk); rst_n=1;
        // 4 种模式 × 多个数据
        for (m = 0; m < 4; m = m + 1) begin
            xfer(m[1], m[0], 8'hA5);
            xfer(m[1], m[0], 8'h3C);
            xfer(m[1], m[0], 8'hFF);
            xfer(m[1], m[0], 8'h01);
        end
        if (errors==0) $display("[PASS] spi_master_modes: 4 种 SPI 模式全双工回环数据/空闲态均正确");
        else            $display("[FAIL] spi_master_modes: %0d 处错误", errors);
        $finish;
    end

    initial begin #500000; $display("[FAIL] spi_master_modes: 超时"); $finish; end
endmodule
