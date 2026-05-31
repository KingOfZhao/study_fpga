`timescale 1ns/1ps
module dds_uart_ctrl_tb;
    localparam PA = 12, AW = 6, DW = 8, CPB = 8;
    reg clk = 0, rst_n;
    reg        snd_dv;
    reg  [7:0] snd_byte;
    wire       snd_serial, snd_active, snd_done;
    wire [PA-1:0] fword;
    wire [DW-1:0] wave;
    integer errors = 0;
    integer cnt_lo, cnt_hi;
    reg prev_msb;

    dds_uart_ctrl #(.PA(PA), .AW(AW), .DW(DW), .CLKS_PER_BIT(CPB)) dut (
        .clk(clk), .rst_n(rst_n), .rx_serial(snd_serial), .fword(fword), .wave(wave));

    uart_tx #(.CLKS_PER_BIT(CPB)) sender (
        .clk(clk), .rst_n(rst_n), .tx_dv(snd_dv), .tx_byte(snd_byte),
        .tx_active(snd_active), .tx_serial(snd_serial), .tx_done(snd_done));

    always #5 clk = ~clk;

    task send_byte(input [7:0] b);
        begin
            @(negedge clk); snd_byte=b; snd_dv=1; @(negedge clk); snd_dv=0;
            wait (snd_done); @(negedge clk);
        end
    endtask

    // 统计一段窗口内 wave 最高位的上升沿数(≈输出频率)
    task count_edges(output integer c);
        integer k;
        begin
            c = 0; prev_msb = wave[DW-1];
            for (k = 0; k < 4000; k = k + 1) begin
                @(negedge clk);
                if (wave[DW-1] && !prev_msb) c = c + 1;
                prev_msb = wave[DW-1];
            end
        end
    endtask

    initial begin
        $dumpfile("dds_uart_ctrl_tb.vcd");
        $dumpvars(0, dds_uart_ctrl_tb);
        rst_n=0; snd_dv=0; snd_byte=0;
        repeat (3) @(negedge clk); rst_n=1;
        // 低频控制字
        send_byte(8'd2);
        repeat (4*CPB) @(negedge clk);   // 等接收端更新 fword
        if (fword !== {8'd2, 4'b0}) begin errors=errors+1; $display("  fword=%h 期望=%h", fword, {8'd2,4'b0}); end
        count_edges(cnt_lo);
        // 高频控制字
        send_byte(8'd20);
        count_edges(cnt_hi);
        $display("  低控制字周期数=%0d, 高控制字周期数=%0d", cnt_lo, cnt_hi);
        if (cnt_lo == 0)        begin errors=errors+1; $display("  低控制字无输出周期"); end
        if (cnt_hi <= cnt_lo)   begin errors=errors+1; $display("  提高控制字后频率未增加"); end
        if (errors==0) $display("[PASS] dds_uart_ctrl: 串口设置控制字实时改变 DDS 输出频率(高字>低字)");
        else            $display("[FAIL] dds_uart_ctrl: %0d 处错误", errors);
        $finish;
    end
    initial begin #5000000; $display("[FAIL] dds_uart_ctrl: 超时"); $finish; end
endmodule
