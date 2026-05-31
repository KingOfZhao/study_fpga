`timescale 1ns/1ps
module spi_link_tb;
    reg clk = 0, rst_n, start;
    reg  [7:0] m_tx, s_tx;
    wire [7:0] m_rx, s_rx;
    wire       s_rx_valid, busy, done;
    integer errors = 0;

    spi_link #(.DIV(4)) dut (
        .clk(clk), .rst_n(rst_n), .start(start), .m_tx(m_tx), .s_tx(s_tx),
        .m_rx(m_rx), .s_rx(s_rx), .s_rx_valid(s_rx_valid), .busy(busy), .done(done));
    always #5 clk = ~clk;

    task xfer(input [7:0] mt, input [7:0] st);
        begin
            m_tx=mt; s_tx=st;
            @(negedge clk); start=1; @(negedge clk); start=0;
            wait (done); @(negedge clk);
            if (m_rx !== st) begin errors=errors+1; $display("  主机收=%h 期望(=从机发)=%h", m_rx, st); end
            if (s_rx !== mt) begin errors=errors+1; $display("  从机收=%h 期望(=主机发)=%h", s_rx, mt); end
            if (m_rx===st && s_rx===mt) $display("  全双工: 主发%h<->从发%h，主收%h 从收%h", mt, st, m_rx, s_rx);
            repeat (8) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("spi_link_tb.vcd");
        $dumpvars(0, spi_link_tb);
        rst_n=0; start=0; m_tx=0; s_tx=0;
        repeat (3) @(negedge clk); rst_n=1;
        xfer(8'hA5, 8'h3C);
        xfer(8'hFF, 8'h00);
        xfer(8'h81, 8'h7E);
        if (errors==0) $display("[PASS] spi_link: SPI 主从全双工交换，主收=从发、从收=主发 全部正确");
        else            $display("[FAIL] spi_link: %0d 处错误", errors);
        $finish;
    end
    initial begin #500000; $display("[FAIL] spi_link: 超时"); $finish; end
endmodule
