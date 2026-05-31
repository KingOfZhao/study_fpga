`timescale 1ns/1ps
module ps2_rx_tb;
    reg clk = 0, rst_n, ps2_clk, ps2_data;
    wire [7:0] data;
    wire valid, err;
    integer errors = 0;
    reg got = 0, err_seen = 0;
    reg [7:0] result;

    ps2_rx dut (.clk(clk), .rst_n(rst_n), .ps2_clk(ps2_clk), .ps2_data(ps2_data),
                .data(data), .valid(valid), .err(err));
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (valid) begin got = 1; result = data; end
        if (err)   err_seen = 1;
    end

    // PS/2 设备：发送一个 bit（数据稳定后产生一个 ps2_clk 下降沿）
    task ps2_bit(input v); begin
        ps2_data = v; #40;
        ps2_clk = 1;  #80;
        ps2_clk = 0;  #80;          // 下降沿采样
    end endtask

    // 发送完整帧：start(0)+8数据(LSB先)+parity+stop(1)
    task ps2_frame(input [7:0] b, input parity);
        integer i;
        begin
            ps2_bit(1'b0);
            for (i = 0; i < 8; i = i + 1) ps2_bit(b[i]);
            ps2_bit(parity);
            ps2_bit(1'b1);
        end
    endtask

    initial begin
        $dumpfile("ps2_rx_tb.vcd");
        $dumpvars(0, ps2_rx_tb);
        rst_n = 0; ps2_clk = 1; ps2_data = 1;
        repeat (4) @(negedge clk); rst_n = 1; #100;
        // 0x1C：3 个 1（奇数），奇校验位=0
        ps2_frame(8'h1C, 1'b0);
        #200;
        if (!got)                 begin errors = errors + 1; $display("  未收到字节"); end
        else if (result !== 8'h1C) begin errors = errors + 1; $display("  收到=%h 期望=0x1C", result); end
        if (err_seen)             begin errors = errors + 1; $display("  正常帧不应报错"); end

        // 错误校验位
        got = 0; err_seen = 0;
        ps2_frame(8'h1C, 1'b1);    // 错误奇偶
        #200;
        if (!err_seen) begin errors = errors + 1; $display("  错误校验位应报 err"); end

        if (errors == 0) $display("[PASS] ps2_rx: 正确接收 0x1C 并能检出校验错误");
        else             $display("[FAIL] ps2_rx: %0d 处错误", errors);
        $finish;
    end

    initial begin #500000; $display("[FAIL] ps2_rx: 超时"); $finish; end
endmodule
