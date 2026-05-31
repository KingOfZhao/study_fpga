`timescale 1ns/1ps
module uart_loopback_tb;
    localparam CPB = 16;
    reg clk = 0, rst_n, tx_dv;
    reg  [7:0] tx_byte;
    wire tx_active, tx_done, rx_dv;
    wire [7:0] rx_byte;
    wire loop_serial;
    integer errors = 0;
    integer i;
    reg [7:0] sent [0:3];
    integer rxcount = 0;

    uart_loopback #(.CLKS_PER_BIT(CPB)) dut (
        .clk(clk), .rst_n(rst_n), .tx_dv(tx_dv), .tx_byte(tx_byte),
        .tx_active(tx_active), .tx_done(tx_done),
        .rx_dv(rx_dv), .rx_byte(rx_byte), .loop_serial(loop_serial));
    always #5 clk = ~clk;

    // 收到字节即与发送队列比对
    always @(posedge clk) begin
        if (rx_dv) begin
            if (rx_byte !== sent[rxcount]) begin
                errors = errors + 1;
                $display("  第 %0d 字节 收=%h 发=%h", rxcount, rx_byte, sent[rxcount]);
            end
            rxcount = rxcount + 1;
        end
    end

    task send(input [7:0] b); begin
        @(negedge clk); tx_byte = b; tx_dv = 1;
        @(negedge clk); tx_dv = 0;
        wait (tx_done);            // 等本字节发完
        @(negedge clk);
    end endtask

    initial begin
        $dumpfile("uart_loopback_tb.vcd");
        $dumpvars(0, uart_loopback_tb);
        rst_n = 0; tx_dv = 0; tx_byte = 0;
        sent[0] = 8'h55; sent[1] = 8'hA3; sent[2] = 8'h0F; sent[3] = 8'hF0;
        repeat (3) @(negedge clk); rst_n = 1;
        for (i = 0; i < 4; i = i + 1) send(sent[i]);
        // 等最后一个字节被接收
        repeat (CPB*12) @(posedge clk);
        if (rxcount != 4) begin errors = errors + 1; $display("  仅收到 %0d 字节", rxcount); end
        if (errors == 0) $display("[PASS] uart_loopback: 4 字节自环收发一致");
        else             $display("[FAIL] uart_loopback: %0d 处错误", errors);
        $finish;
    end

    initial begin #500000; $display("[FAIL] uart_loopback: 超时"); $finish; end
endmodule
