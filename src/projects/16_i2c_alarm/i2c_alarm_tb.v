`timescale 1ns/1ps
module i2c_alarm_tb;
    localparam integer DIV = 4;
    localparam [6:0]   DEV_ADDR = 7'h27;
    reg clk = 0, rst_n, go;
    reg  [7:0] threshold;
    reg  [7:0] sensor_data;          // 可变的“传感器读数”
    wire [7:0] value;
    wire       valid, alarm, ack_err;
    wire       scl, sda_oe;
    integer errors = 0, i;

    // 开漏总线
    wire sda;
    reg  s_sda_low = 1'b0;
    pullup (sda);
    assign sda = sda_oe   ? 1'b0 : 1'bz;
    assign sda = s_sda_low ? 1'b0 : 1'bz;

    i2c_alarm #(.DIV(DIV), .DEV_ADDR(DEV_ADDR)) dut (
        .clk(clk), .rst_n(rst_n), .go(go), .threshold(threshold),
        .value(value), .valid(valid), .alarm(alarm), .ack_err(ack_err),
        .scl(scl), .sda_oe(sda_oe), .sda_i(sda));
    always #5 clk = ~clk;

    // I2C 从机模型（读事务，MSB 先）
    reg [7:0] raddr;
    initial begin
        s_sda_low = 1'b0;
        forever begin
            @(negedge sda);
            if (scl === 1'b1) begin
                for (i = 0; i < 8; i = i + 1) begin @(posedge scl); raddr[7-i] = sda; end
                @(negedge scl);
                if (raddr[7:1] == DEV_ADDR) s_sda_low = 1'b1;
                @(posedge scl);
                @(negedge scl); s_sda_low = 1'b0;
                if (raddr[7:1] == DEV_ADDR && raddr[0] == 1'b1) begin
                    for (i = 0; i < 8; i = i + 1) begin
                        s_sda_low = (sensor_data[7-i] == 1'b0) ? 1'b1 : 1'b0;
                        @(posedge scl); @(negedge scl);
                    end
                    s_sda_low = 1'b0;
                end
                // 等待 STOP 后总线空闲，避免把 NACK/STOP 的边沿误判为新 START
                wait (scl === 1'b1 && sda === 1'b1);
            end
        end
    end

    task do_read(input [7:0] sval, input [7:0] thr, input expect_alarm);
        begin
            sensor_data = sval; threshold = thr;
            @(negedge clk); go=1; @(negedge clk); go=0;
            wait (valid); @(negedge clk);
            if (value !== sval) begin errors=errors+1; $display("  读数=%h 期望=%h", value, sval); end
            if (alarm !== expect_alarm) begin errors=errors+1; $display("  value=%0d thr=%0d alarm=%b 期望=%b", sval, thr, alarm, expect_alarm); end
            else $display("  读数=%0d 阈值=%0d -> alarm=%b", sval, thr, alarm);
            repeat (40) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("i2c_alarm_tb.vcd");
        $dumpvars(0, i2c_alarm_tb);
        rst_n=0; go=0; threshold=8'd128; sensor_data=8'h00;
        repeat (3) @(negedge clk); rst_n=1;
        do_read(8'd100, 8'd128, 1'b0);   // 低于阈值 -> 不报警
        do_read(8'd200, 8'd128, 1'b1);   // 高于阈值 -> 报警
        if (errors==0) $display("[PASS] i2c_alarm: I2C 读取传感器并按阈值正确产生/清除报警");
        else            $display("[FAIL] i2c_alarm: %0d 处错误", errors);
        $finish;
    end
    initial begin #2000000; $display("[FAIL] i2c_alarm: 超时"); $finish; end
endmodule
