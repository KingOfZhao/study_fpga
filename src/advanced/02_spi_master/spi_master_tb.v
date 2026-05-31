// spi_master 自校验 testbench
// 用 MISO=MOSI 的回环：主机发出什么，就应在 rx_data 收到什么。
`timescale 1ns/1ps

module spi_master_tb;
    localparam CLK_DIV = 4;

    reg        clk = 0;
    reg        rst_n;
    reg        start;
    reg  [7:0] tx_data;
    wire       sclk, mosi, cs_n, busy, done;
    wire [7:0] rx_data;
    integer    errors = 0;

    // 回环：从机把收到的位原样返回
    wire miso = mosi;

    spi_master #(.CLK_DIV(CLK_DIV)) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start), .tx_data(tx_data), .miso(miso),
        .sclk(sclk), .mosi(mosi), .cs_n(cs_n),
        .rx_data(rx_data), .busy(busy), .done(done)
    );

    always #5 clk = ~clk;

    task xfer_and_check(input [7:0] data);
        integer timeout;
        begin
            @(negedge clk);
            while (busy) @(negedge clk);
            tx_data = data;
            start   = 1'b1;
            @(negedge clk);
            start   = 1'b0;

            // 等待 done
            timeout = 0;
            while (done !== 1'b1 && timeout < 100 * CLK_DIV) begin
                @(posedge clk); #1;
                timeout = timeout + 1;
            end

            if (done !== 1'b1) begin
                errors = errors + 1;
                $display("[FAIL] 0x%02h: timeout, no done", data);
            end else if (rx_data !== data) begin
                errors = errors + 1;
                $display("[FAIL] sent 0x%02h, loopback rx 0x%02h", data, rx_data);
            end else
                $display("[ OK ] sent 0x%02h, loopback rx 0x%02h", data, rx_data);
        end
    endtask

    initial begin
        $dumpfile("spi_master_tb.vcd");
        $dumpvars(0, spi_master_tb);

        start = 0; tx_data = 0; rst_n = 0;
        repeat (3) @(posedge clk); rst_n = 1;
        repeat (2) @(posedge clk);

        xfer_and_check(8'hA5);
        xfer_and_check(8'h3C);
        xfer_and_check(8'hFF);
        xfer_and_check(8'h01);

        if (errors == 0)
            $display("[PASS] spi_master: loopback bytes match");
        else begin
            $display("[FAIL] spi_master: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
