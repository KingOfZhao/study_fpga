`timescale 1ns/1ps
module manchester_dec_tb;
    reg clk = 0, rst_n, chip, chip_valid;
    wire [7:0] data;
    wire data_valid, code_err;
    integer errors = 0;
    integer i;
    reg [7:0] src;
    reg got = 0, err_seen = 0;
    reg [7:0] result;

    manchester_dec dut (.clk(clk), .rst_n(rst_n), .chip(chip), .chip_valid(chip_valid),
                        .data(data), .data_valid(data_valid), .code_err(code_err));
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (data_valid) begin got = 1; result = data; end
        if (code_err)   err_seen = 1;
    end

    // 发送一个 chip（占一个时钟）
    task send_chip(input v); begin
        @(negedge clk); chip = v; chip_valid = 1;
        @(negedge clk); chip_valid = 0;
    end endtask

    // 正常发送一个字节（每位 bit,~bit）
    task send_byte(input [7:0] b); begin
        for (i = 0; i < 8; i = i + 1) begin
            send_chip(b[i]); send_chip(~b[i]);
        end
    end endtask

    initial begin
        $dumpfile("manchester_dec_tb.vcd");
        $dumpvars(0, manchester_dec_tb);
        rst_n = 0; chip = 0; chip_valid = 0; src = 8'hB4;
        @(negedge clk); rst_n = 1;
        // 正常字节
        send_byte(src);
        repeat (4) @(posedge clk);
        if (!got)               begin errors = errors + 1; $display("  未解码出字节"); end
        else if (result !== src) begin errors = errors + 1; $display("  解码=%h 期望=%h", result, src); end
        if (err_seen) begin errors = errors + 1; $display("  正常流不应报 code_err"); end

        // 非法流：两个相同 chip（违反曼彻斯特互补）
        err_seen = 0;
        send_chip(1'b1); send_chip(1'b1);
        repeat (4) @(posedge clk);
        if (!err_seen) begin errors = errors + 1; $display("  非法流应报 code_err"); end

        if (errors == 0) $display("[PASS] manchester_dec: 正常解码 0xB4 且能检出编码错误");
        else             $display("[FAIL] manchester_dec: %0d 处错误", errors);
        $finish;
    end

    initial begin #200000; $display("[FAIL] manchester_dec: 超时"); $finish; end
endmodule
