`timescale 1ns/1ps
module crc16_tb;
    reg clk = 0, rst_n, clr, bit_in, bit_valid;
    wire [15:0] crc;
    integer errors = 0;
    integer i, k;
    reg [7:0] msg [0:8];

    crc16 dut (.clk(clk), .rst_n(rst_n), .clr(clr), .bit_in(bit_in), .bit_valid(bit_valid), .crc(crc));
    always #5 clk = ~clk;

    task feed_byte(input [7:0] b);
        begin
            for (k = 7; k >= 0; k = k - 1) begin
                @(negedge clk); bit_in = b[k]; bit_valid = 1;
                @(negedge clk); bit_valid = 0;
            end
        end
    endtask

    initial begin
        $dumpfile("crc16_tb.vcd");
        $dumpvars(0, crc16_tb);
        msg[0]="1"; msg[1]="2"; msg[2]="3"; msg[3]="4"; msg[4]="5";
        msg[5]="6"; msg[6]="7"; msg[7]="8"; msg[8]="9";
        rst_n = 0; clr = 0; bit_in = 0; bit_valid = 0;
        @(negedge clk); rst_n = 1;
        @(negedge clk); clr = 1; @(negedge clk); clr = 0;
        for (i = 0; i < 9; i = i + 1) feed_byte(msg[i]);
        @(negedge clk);
        if (crc !== 16'h29B1) begin
            errors = errors + 1;
            $display("  CRC=%h 期望=0x29B1", crc);
        end
        if (errors == 0) $display("[PASS] crc16: \"123456789\" CRC-16/CCITT=0x%0h 正确", crc);
        else             $display("[FAIL] crc16: %0d 处错误", errors);
        $finish;
    end
endmodule
