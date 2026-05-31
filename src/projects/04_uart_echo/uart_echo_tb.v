`timescale 1ns/1ps
module uart_echo_tb;
    localparam CPB = 8;
    reg clk = 0, rst_n;
    wire dut_tx, dut_tx_active;
    // 发送端(模拟外部主机) -> dut.rx
    reg        snd_dv;
    reg  [7:0] snd_byte;
    wire       snd_serial, snd_active, snd_done;
    // 监视端：解码 dut.tx
    wire       mon_dv;
    wire [7:0] mon_byte;

    integer errors = 0, i, got = 0;
    reg [7:0] expq [0:3];

    uart_echo #(.CLKS_PER_BIT(CPB), .DEPTH(16)) dut (
        .clk(clk), .rst_n(rst_n), .rx_serial(snd_serial),
        .tx_serial(dut_tx), .tx_active(dut_tx_active));

    uart_tx #(.CLKS_PER_BIT(CPB)) sender (
        .clk(clk), .rst_n(rst_n), .tx_dv(snd_dv), .tx_byte(snd_byte),
        .tx_active(snd_active), .tx_serial(snd_serial), .tx_done(snd_done));

    uart_rx #(.CLKS_PER_BIT(CPB)) monitor (
        .clk(clk), .rst_n(rst_n), .rx_serial(dut_tx),
        .rx_dv(mon_dv), .rx_byte(mon_byte));

    always #5 clk = ~clk;

    // 监视回显输出
    always @(posedge clk) begin
        if (rst_n && mon_dv) begin
            if (mon_byte !== expq[got]) begin
                errors=errors+1; $display("  回显%0d=%h 期望=%h", got, mon_byte, expq[got]);
            end else $display("  回显字节%0d=%h", got, mon_byte);
            got = got + 1;
        end
    end

    initial begin
        $dumpfile("uart_echo_tb.vcd");
        $dumpvars(0, uart_echo_tb);
        expq[0]=8'h55; expq[1]=8'hA3; expq[2]=8'h0F; expq[3]=8'hF0;
        rst_n=0; snd_dv=0; snd_byte=0;
        repeat (3) @(negedge clk); rst_n=1;
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk); snd_byte=expq[i]; snd_dv=1;
            @(negedge clk); snd_dv=0;
            wait (snd_done); @(negedge clk);
        end
        // 等待全部回显完成
        wait (got == 4);
        repeat (10) @(negedge clk);
        if (errors==0) $display("[PASS] uart_echo: 4 字节经 RX->FIFO->TX 缓冲回显，内容/顺序正确");
        else            $display("[FAIL] uart_echo: %0d 处错误", errors);
        $finish;
    end
    initial begin #2000000; $display("[FAIL] uart_echo: 超时 (got=%0d)", got); $finish; end
endmodule
