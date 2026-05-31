// sync_fifo 自校验 testbench
`timescale 1ns/1ps

module sync_fifo_tb;
    localparam WIDTH = 8;
    localparam DEPTH = 16;

    reg              clk = 0;
    reg              rst_n;
    reg              wr_en, rd_en;
    reg  [WIDTH-1:0] wr_data;
    wire [WIDTH-1:0] rd_data;
    wire             full, empty;
    wire [4:0]       count;
    integer          errors = 0;
    integer          i;
    reg  [WIDTH-1:0] got;

    sync_fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr_en), .wr_data(wr_data),
        .rd_en(rd_en), .rd_data(rd_data),
        .full(full), .empty(empty), .count(count)
    );

    always #5 clk = ~clk;

    task fifo_write(input [WIDTH-1:0] data);
        begin
            @(negedge clk); wr_en = 1'b1; wr_data = data;
            @(negedge clk); wr_en = 1'b0;
        end
    endtask

    task fifo_read(output [WIDTH-1:0] data);
        begin
            @(negedge clk); rd_en = 1'b1;
            @(negedge clk); rd_en = 1'b0;  // 期间一个上升沿完成读，rd_data 已更新
            data = rd_data;
        end
    endtask

    task expect_flag(input got_v, input exp_v, input [255:0] name);
        begin
            if (got_v !== exp_v) begin
                errors = errors + 1;
                $display("[FAIL] %0s: got=%b exp=%b", name, got_v, exp_v);
            end else $display("[ OK ] %0s = %b", name, got_v);
        end
    endtask

    initial begin
        $dumpfile("sync_fifo_tb.vcd");
        $dumpvars(0, sync_fifo_tb);

        wr_en = 0; rd_en = 0; wr_data = 0;
        rst_n = 0; repeat (2) @(posedge clk); rst_n = 1; @(negedge clk);

        expect_flag(empty, 1'b1, "empty after reset");
        expect_flag(full,  1'b0, "not full after reset");

        // 写满 DEPTH 个：值为 10,11,...
        for (i = 0; i < DEPTH; i = i + 1)
            fifo_write(i[WIDTH-1:0] + 8'd10);
        expect_flag(full,  1'b1, "full after DEPTH writes");
        expect_flag(empty, 1'b0, "not empty when full");
        if (count !== DEPTH) begin
            errors = errors + 1;
            $display("[FAIL] count: got=%0d exp=%0d", count, DEPTH);
        end else $display("[ OK ] count = %0d", count);

        // 满时再写应被忽略
        fifo_write(8'hEE);
        expect_flag(full, 1'b1, "still full after overflow write");

        // 顺序读出，应与写入顺序一致（FIFO）
        for (i = 0; i < DEPTH; i = i + 1) begin
            fifo_read(got);
            if (got !== (i[WIDTH-1:0] + 8'd10)) begin
                errors = errors + 1;
                $display("[FAIL] read %0d: got=%0d exp=%0d", i, got, i + 10);
            end else $display("[ OK ] read %0d = %0d", i, got);
        end

        expect_flag(empty, 1'b1, "empty after reading all");

        // 空时读不应改变 empty
        fifo_read(got);
        expect_flag(empty, 1'b1, "still empty after underflow read");

        if (errors == 0)
            $display("[PASS] sync_fifo: all assertions passed");
        else begin
            $display("[FAIL] sync_fifo: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
