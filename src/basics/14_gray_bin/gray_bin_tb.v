`timescale 1ns/1ps
module gray_bin_tb;
    localparam W = 4;
    reg  [W-1:0] bin_in, gray_in;
    wire [W-1:0] gray, bin_out;
    integer errors = 0;
    integer i, b, diffbits;
    reg [W-1:0] prev_gray;
    reg [W-1:0] xorval;

    gray_bin #(.W(W)) dut (.bin_in(bin_in), .gray(gray), .gray_in(gray_in), .bin_out(bin_out));

    initial begin
        $dumpfile("gray_bin_tb.vcd");
        $dumpvars(0, gray_bin_tb);
        prev_gray = 0;
        for (i = 0; i < (1<<W); i = i + 1) begin
            bin_in = i[W-1:0];
            #1;
            // 往返一致：gray2bin(bin2gray(x)) == x
            gray_in = gray;
            #1;
            if (bin_out !== bin_in) begin
                errors = errors + 1;
                $display("  ROUNDTRIP FAIL bin=%b gray=%b back=%b", bin_in, gray, bin_out);
            end
            // 相邻码只差 1 位（格雷码性质），跳过 i=0
            xorval = gray ^ prev_gray;
            diffbits = 0;
            for (b = 0; b < W; b = b + 1) diffbits = diffbits + xorval[b];
            if (i > 0 && diffbits != 1) begin
                errors = errors + 1;
                $display("  ADJ FAIL i=%0d gray=%b prev=%b diff=%0d", i, gray, prev_gray, diffbits);
            end
            prev_gray = gray;
        end
        if (errors == 0) $display("[PASS] gray_bin: 往返一致且相邻仅 1 位变化");
        else             $display("[FAIL] gray_bin: %0d 处错误", errors);
        $finish;
    end
endmodule
