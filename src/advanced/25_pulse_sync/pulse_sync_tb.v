`timescale 1ns/1ps
module pulse_sync_tb;
    reg src_clk=0, dst_clk=0, src_rst_n, dst_rst_n, src_pulse;
    wire dst_pulse;
    integer sent = 0, recv = 0;
    integer i;

    pulse_sync dut (.src_clk(src_clk), .src_rst_n(src_rst_n), .src_pulse(src_pulse),
                    .dst_clk(dst_clk), .dst_rst_n(dst_rst_n), .dst_pulse(dst_pulse));

    always #5  src_clk = ~src_clk;    // 源域 100MHz
    always #17 dst_clk = ~dst_clk;    // 目的域 ~29MHz (异步、不同频)

    // 目的域计数收到的脉冲
    always @(posedge dst_clk) if (dst_rst_n && dst_pulse) recv = recv + 1;

    // 源域发一个单拍脉冲
    task send_pulse;
        begin
            @(negedge src_clk); src_pulse = 1; sent = sent + 1;
            @(negedge src_clk); src_pulse = 0;
        end
    endtask

    initial begin
        $dumpfile("pulse_sync_tb.vcd");
        $dumpvars(0, pulse_sync_tb);
        src_rst_n=0; dst_rst_n=0; src_pulse=0;
        repeat (3) @(negedge src_clk); src_rst_n=1; dst_rst_n=1;
        // 发若干脉冲，每个之间留足够间隔让目的域采到
        for (i = 0; i < 10; i = i + 1) begin
            send_pulse;
            repeat (8) @(negedge src_clk);   // 间隔 > 目的域 2~3 拍
        end
        repeat (20) @(negedge dst_clk);
        if (sent == recv && sent == 10)
            $display("[PASS] pulse_sync: 跨时钟域 %0d 个脉冲全部无丢失/无重复传递 (收=%0d)", sent, recv);
        else
            $display("[FAIL] pulse_sync: 发=%0d 收=%0d", sent, recv);
        $finish;
    end
    initial begin #100000; $display("[FAIL] pulse_sync: 超时"); $finish; end
endmodule
