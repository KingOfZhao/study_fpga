`timescale 1ns/1ps
module uart_tx_fifo_tb;
    localparam CLKS_PER_BIT = 8;
    reg clk = 0, rst_n, wr;
    reg  [7:0] din;
    wire full, tx_serial, tx_active;
    integer errors = 0;
    integer i;
    reg [7:0] rxb;
    reg [7:0] expq [0:3];
    integer got = 0;

    uart_tx_fifo #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut (
        .clk(clk), .rst_n(rst_n), .wr(wr), .din(din), .full(full),
        .tx_serial(tx_serial), .tx_active(tx_active));
    always #5 clk = ~clk;

    // 串口接收：等起始位，逐位中点采样
    task recv_byte(output [7:0] b);
        integer k;
        begin
            @(negedge tx_serial);            // 起始位下降沿
            repeat (CLKS_PER_BIT + CLKS_PER_BIT/2) @(posedge clk);  // 跳过起始位到第0位中点
            for (k = 0; k < 8; k = k + 1) begin
                b[k] = tx_serial;
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
        end
    endtask

    initial begin
        expq[0]=8'h3A; expq[1]=8'hC5; expq[2]=8'h00; expq[3]=8'hFF;
        $dumpfile("uart_tx_fifo_tb.vcd");
        $dumpvars(0, uart_tx_fifo_tb);
        rst_n = 0; wr = 0; din = 0;
        repeat (2) @(negedge clk); rst_n = 1;
        // 连续写 4 字节
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk); wr = 1; din = expq[i];
        end
        @(negedge clk); wr = 0;
    end

    initial begin
        @(posedge rst_n);
        for (got = 0; got < 4; got = got + 1) begin
            recv_byte(rxb);
            if (rxb !== expq[got]) begin
                errors = errors + 1;
                $display("  第%0d字节 收到=%h 期望=%h", got, rxb, expq[got]);
            end else
                $display("  收到字节%0d = %h", got, rxb);
        end
        if (errors == 0) $display("[PASS] uart_tx_fifo: FIFO 缓冲的 4 字节按序正确发出");
        else             $display("[FAIL] uart_tx_fifo: %0d 处错误", errors);
        $finish;
    end

    initial begin #500000; $display("[FAIL] uart_tx_fifo: 超时"); $finish; end
endmodule
