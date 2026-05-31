`timescale 1ns/1ps
module async_fifo_tb;
    localparam W = 8, AW = 4, N = 12;
    reg wr_clk = 0, rd_clk = 0, wr_rst_n, rd_rst_n;
    reg wr_en, rd_en;
    reg  [W-1:0] wr_data;
    wire [W-1:0] rd_data;
    wire wr_full, rd_empty;
    integer errors = 0;
    integer i;
    reg [W-1:0] got;

    async_fifo #(.W(W), .AW(AW)) dut (
        .wr_clk(wr_clk), .wr_rst_n(wr_rst_n), .wr_en(wr_en), .wr_data(wr_data), .wr_full(wr_full),
        .rd_clk(rd_clk), .rd_rst_n(rd_rst_n), .rd_en(rd_en), .rd_data(rd_data), .rd_empty(rd_empty));

    always #5  wr_clk = ~wr_clk;   // 100MHz
    always #7  rd_clk = ~rd_clk;   // 异步、较慢

    initial begin
        $dumpfile("async_fifo_tb.vcd");
        $dumpvars(0, async_fifo_tb);
        wr_rst_n = 0; rd_rst_n = 0; wr_en = 0; rd_en = 0; wr_data = 0;
        repeat (3) @(posedge wr_clk);
        wr_rst_n = 1;
        repeat (3) @(posedge rd_clk);
        rd_rst_n = 1;

        // 写入 N 个数据 0xA0..
        for (i = 0; i < N; i = i + 1) begin
            @(negedge wr_clk);
            wr_data = 8'hA0 + i[7:0];
            wr_en   = 1;
            @(negedge wr_clk);
            wr_en   = 0;
        end

        // 等待指针同步穿过时钟域
        repeat (6) @(posedge rd_clk);

        // 读出 N 个，校验顺序
        for (i = 0; i < N; i = i + 1) begin
            while (rd_empty) @(posedge rd_clk);
            got = rd_data;                 // FWFT：先取头
            if (got !== (8'hA0 + i[7:0])) begin
                errors = errors + 1;
                $display("  第 %0d 个读出=%h 期望=%h", i, got, 8'hA0 + i[7:0]);
            end
            @(negedge rd_clk); rd_en = 1; @(negedge rd_clk); rd_en = 0;  // 推进
        end

        repeat (6) @(posedge rd_clk);
        if (!rd_empty) begin errors = errors + 1; $display("  读空后应 empty"); end

        if (errors == 0) $display("[PASS] async_fifo: 跨时钟写入/读出 %0d 个数据顺序正确", N);
        else             $display("[FAIL] async_fifo: %0d 处错误", errors);
        $finish;
    end

    initial begin #100000; $display("[FAIL] async_fifo: 超时"); $finish; end
endmodule
