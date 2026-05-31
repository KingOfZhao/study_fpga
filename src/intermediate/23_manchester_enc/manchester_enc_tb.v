`timescale 1ns/1ps
module manchester_enc_tb;
    reg clk = 0, rst_n, start;
    reg  [7:0] data;
    wire tx, active, done;
    integer errors = 0;
    integer i;
    reg [0:15] chips;          // 采集到的 16 个 chip
    integer ci = 0;

    manchester_enc dut (.clk(clk), .rst_n(rst_n), .start(start), .data(data),
                        .tx(tx), .active(active), .done(done));
    always #5 clk = ~clk;

    always @(posedge clk) if (active) begin chips[ci] = tx; ci = ci + 1; end

    reg expbit;
    initial begin
        $dumpfile("manchester_enc_tb.vcd");
        $dumpvars(0, manchester_enc_tb);
        rst_n = 0; start = 0; data = 8'hB4;
        @(negedge clk); rst_n = 1;
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        wait (done);
        @(posedge clk);
        // 校验每个数据位(LSB先)对应两个 chip: [bit, ~bit]
        for (i = 0; i < 8; i = i + 1) begin
            expbit = data[i];
            if (chips[2*i] !== expbit || chips[2*i+1] !== ~expbit) begin
                errors = errors + 1;
                $display("  bit%0d=%b chips=%b%b 期望 %b%b", i, expbit,
                          chips[2*i], chips[2*i+1], expbit, ~expbit);
            end
        end
        if (ci != 16) begin errors = errors + 1; $display("  chip 数=%0d 期望 16", ci); end
        if (errors == 0) $display("[PASS] manchester_enc: 0xB4 编码为 16 个 chip 正确");
        else             $display("[FAIL] manchester_enc: %0d 处错误", errors);
        $finish;
    end

    initial begin #100000; $display("[FAIL] manchester_enc: 超时"); $finish; end
endmodule
