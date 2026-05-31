`timescale 1ns/1ps
module button_uart_report_tb;
    localparam CPB = 8, DB_N = 4;
    reg clk = 0, rst_n, btn_in;
    wire tx_serial, tx_active;
    wire [7:0] count;
    wire       mon_dv;
    wire [7:0] mon_byte;
    integer errors = 0, i, j, got = 0;

    button_uart_report #(.DB_N(DB_N), .CLKS_PER_BIT(CPB)) dut (
        .clk(clk), .rst_n(rst_n), .btn_in(btn_in),
        .tx_serial(tx_serial), .tx_active(tx_active), .count(count));

    uart_rx #(.CLKS_PER_BIT(CPB)) monitor (
        .clk(clk), .rst_n(rst_n), .rx_serial(tx_serial),
        .rx_dv(mon_dv), .rx_byte(mon_byte));

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rst_n && mon_dv) begin
            got = got + 1;
            if (mon_byte !== got[7:0]) begin
                errors=errors+1; $display("  第%0d次上报=%h 期望=%0d", got, mon_byte, got);
            end else $display("  上报计数=%0d", mon_byte);
        end
    end

    // 带抖动的一次按下
    task press;
        begin
            for (j = 0; j < 6; j = j + 1) begin btn_in = $random; @(negedge clk); end
            btn_in = 1; repeat (DB_N+4) @(negedge clk);   // 稳定按下
            for (j = 0; j < 6; j = j + 1) begin btn_in = $random; @(negedge clk); end
            btn_in = 0; repeat (DB_N+4) @(negedge clk);   // 稳定松开
        end
    endtask

    initial begin
        $dumpfile("button_uart_report_tb.vcd");
        $dumpvars(0, button_uart_report_tb);
        rst_n=0; btn_in=0;
        repeat (3) @(negedge clk); rst_n=1;
        for (i = 0; i < 3; i = i + 1) begin
            press;
            // 等本次 UART 发送完毕（一帧 ~10*CPB 拍）
            repeat (12*CPB) @(negedge clk);
        end
        wait (got == 3);
        if (errors==0 && count==3)
            $display("[PASS] button_uart_report: 3 次去抖按下计数并串口上报 1,2,3 正确");
        else
            $display("[FAIL] button_uart_report: errors=%0d count=%0d got=%0d", errors, count, got);
        $finish;
    end
    initial begin #3000000; $display("[FAIL] button_uart_report: 超时 (got=%0d)", got); $finish; end
endmodule
