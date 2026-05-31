`timescale 1ns/1ps
module hamming74_tb;
    reg  [3:0] data;
    wire [6:0] code;
    reg  [6:0] rx;
    wire [3:0] dec_data;
    wire [2:0] syndrome;
    wire       corrected;
    integer errors = 0;
    integer d, b;
    reg [6:0] enc;

    hamming74 dut (.data(data), .code(code), .rx(rx),
                   .dec_data(dec_data), .syndrome(syndrome), .corrected(corrected));

    initial begin
        $dumpfile("hamming74_tb.vcd");
        $dumpvars(0, hamming74_tb);
        for (d = 0; d < 16; d = d + 1) begin
            data = d[3:0];
            #1; enc = code;
            // 无错
            rx = enc; #1;
            if (syndrome !== 3'd0 || corrected !== 1'b0 || dec_data !== data) begin
                errors = errors + 1;
                $display("  无错 data=%h dec=%h syn=%0d corr=%b", data, dec_data, syndrome, corrected);
            end
            // 单 bit 错（7 个位置）
            for (b = 0; b < 7; b = b + 1) begin
                rx = enc ^ (7'd1 << b); #1;
                if (dec_data !== data || corrected !== 1'b1 || syndrome !== (b[2:0] + 3'd1)) begin
                    errors = errors + 1;
                    $display("  data=%h 翻转位%0d -> dec=%h syn=%0d corr=%b",
                              data, b, dec_data, syndrome, corrected);
                end
            end
        end
        if (errors == 0) $display("[PASS] hamming74: 16 数据 x (无错+7 单错) 全部纠正正确");
        else             $display("[FAIL] hamming74: %0d 处错误", errors);
        $finish;
    end
endmodule
