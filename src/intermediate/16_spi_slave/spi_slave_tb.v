`timescale 1ns/1ps
module spi_slave_tb;
    reg clk = 0, rst_n, sclk, cs_n, mosi;
    reg  [7:0] tx_byte;
    wire miso;
    wire [7:0] rx_byte;
    wire rx_valid;
    integer errors = 0;
    reg [7:0] master_rx;

    spi_slave dut (.clk(clk), .rst_n(rst_n), .sclk(sclk), .cs_n(cs_n), .mosi(mosi),
                   .tx_byte(tx_byte), .miso(miso), .rx_byte(rx_byte), .rx_valid(rx_valid));
    always #5 clk = ~clk;     // 系统时钟 100MHz

    // 主机模型（模式0），慢速 sclk，半周期 60ns
    task spi_xfer(input [7:0] mo, output [7:0] mi);
        integer k;
        begin
            cs_n = 0; #100;
            for (k = 7; k >= 0; k = k - 1) begin
                mosi = mo[k]; #60;
                sclk = 1; #30; mi[k] = miso; #30;   // 上升沿采样 MISO
                sclk = 0; #60;
            end
            #60; cs_n = 1; #100;
        end
    endtask

    task check(input [7:0] mo, input [7:0] slv_tx);
        begin
            tx_byte = slv_tx;
            spi_xfer(mo, master_rx);
            if (rx_byte !== mo) begin
                errors = errors + 1;
                $display("  从机收=%h 主机发=%h", rx_byte, mo);
            end
            if (master_rx !== slv_tx) begin
                errors = errors + 1;
                $display("  主机收=%h 从机发=%h", master_rx, slv_tx);
            end
        end
    endtask

    initial begin
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, spi_slave_tb);
        rst_n = 0; sclk = 0; cs_n = 1; mosi = 0; tx_byte = 0; master_rx = 0;
        repeat (4) @(negedge clk); rst_n = 1; #50;
        check(8'hA5, 8'h3C);
        check(8'h5A, 8'hF0);
        check(8'hFF, 8'h81);
        if (errors == 0) $display("[PASS] spi_slave: 三次全双工传输收发一致");
        else             $display("[FAIL] spi_slave: %0d 处错误", errors);
        $finish;
    end

    initial begin #2000000; $display("[FAIL] spi_slave: 超时"); $finish; end
endmodule
