`timescale 1ns/1ps
module adc_movavg_uart_tb;
    localparam DW = 8, N = 4, CPB = 8;
    reg clk = 0, rst_n, sample_valid;
    reg  [DW-1:0] sample;
    wire [DW-1:0] filtered;
    wire tx_serial, tx_active;
    wire mon_dv;
    wire [7:0] mon_byte;
    integer errors = 0, i, got = 0;
    reg  [DW-1:0] win [0:N-1];
    reg  [DW-1:0] samples [0:5];
    integer sum;
    reg  [DW-1:0] expq [0:5];

    adc_movavg_uart #(.DW(DW), .N(N), .CLKS_PER_BIT(CPB)) dut (
        .clk(clk), .rst_n(rst_n), .sample_valid(sample_valid), .sample(sample),
        .filtered(filtered), .tx_serial(tx_serial), .tx_active(tx_active));

    uart_rx #(.CLKS_PER_BIT(CPB)) monitor (
        .clk(clk), .rst_n(rst_n), .rx_serial(tx_serial), .rx_dv(mon_dv), .rx_byte(mon_byte));

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rst_n && mon_dv) begin
            if (mon_byte !== expq[got]) begin errors=errors+1; $display("  上报%0d=%0d 期望=%0d", got, mon_byte, expq[got]); end
            else $display("  滤波上报[%0d]=%0d", got, mon_byte);
            got = got + 1;
        end
    end

    initial begin
        $dumpfile("adc_movavg_uart_tb.vcd");
        $dumpvars(0, adc_movavg_uart_tb);
        samples[0]=8'd40; samples[1]=8'd80; samples[2]=8'd120; samples[3]=8'd160;
        samples[4]=8'd200; samples[5]=8'd100;
        // 参考：N 点移动平均(初始窗口为 0)
        for (i = 0; i < N; i = i + 1) win[i]=0;
        for (i = 0; i < 6; i = i + 1) begin
            win[3]=win[2]; win[2]=win[1]; win[1]=win[0]; win[0]=samples[i];
            sum = win[0]+win[1]+win[2]+win[3];
            expq[i] = sum / N;
        end
        rst_n=0; sample_valid=0; sample=0;
        repeat (3) @(negedge clk); rst_n=1;
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk); sample=samples[i]; sample_valid=1;
            @(negedge clk); sample_valid=0;
            repeat (12*CPB) @(negedge clk);   // 等本次 UART 发送完成
        end
        wait (got == 6);
        if (errors==0) $display("[PASS] adc_movavg_uart: 6 个样本经移动平均滤波并串口上报数值正确");
        else            $display("[FAIL] adc_movavg_uart: %0d 处错误", errors);
        $finish;
    end
    initial begin #5000000; $display("[FAIL] adc_movavg_uart: 超时 (got=%0d)", got); $finish; end
endmodule
