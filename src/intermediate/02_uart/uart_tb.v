// UART 回环自校验 testbench：TX 的输出直接接 RX 的输入，发什么应收到什么。
`timescale 1ns/1ps

module uart_tb;
    localparam CLKS_PER_BIT = 8;   // 仿真用小值；上板时 = 时钟频率/波特率

    reg        clk = 0;
    reg        rst_n;
    integer    errors = 0;

    // TX 侧
    reg        tx_dv;
    reg  [7:0] tx_byte;
    wire       tx_active, tx_serial, tx_done;

    // RX 侧
    wire       rx_dv;
    wire [7:0] rx_byte;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst_n(rst_n),
        .tx_dv(tx_dv), .tx_byte(tx_byte),
        .tx_active(tx_active), .tx_serial(tx_serial), .tx_done(tx_done)
    );

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk), .rst_n(rst_n),
        .rx_serial(tx_serial),       // 回环连接
        .rx_dv(rx_dv), .rx_byte(rx_byte)
    );

    always #5 clk = ~clk;

    // 发送一个字节并等待 RX 收到，校验数据一致
    task send_and_check(input [7:0] data);
        integer timeout;
        begin
            // 先确保发送器空闲
            @(negedge clk);
            while (tx_active) @(negedge clk);
            tx_byte = data;
            tx_dv   = 1'b1;
            // 保持 tx_dv 直到发送器真正开始，避免脉冲恰好落在 CLEAN 周期被漏掉
            @(posedge tx_active);
            @(negedge clk);
            tx_dv   = 1'b0;

            // 等待 rx_dv（带超时保护）
            timeout = 0;
            while (rx_dv !== 1'b1 && timeout < 40 * CLKS_PER_BIT) begin
                @(posedge clk); #1;
                timeout = timeout + 1;
            end

            if (rx_dv !== 1'b1) begin
                errors = errors + 1;
                $display("[FAIL] 0x%02h: timeout, no rx_dv", data);
            end else if (rx_byte !== data) begin
                errors = errors + 1;
                $display("[FAIL] sent 0x%02h, received 0x%02h", data, rx_byte);
            end else begin
                $display("[ OK ] sent 0x%02h, received 0x%02h", data, rx_byte);
            end
        end
    endtask

    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        rst_n = 1'b0; tx_dv = 1'b0; tx_byte = 8'd0;
        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        send_and_check(8'hA5);
        send_and_check(8'h3C);
        send_and_check(8'hFF);
        send_and_check(8'h00);

        if (errors == 0)
            $display("[PASS] uart loopback: all bytes match");
        else begin
            $display("[FAIL] uart loopback: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
