`timescale 1ns/1ps
module vga_pattern_tb;
    localparam HACT = 640, BARS = 8, CW = 4, BARW = HACT/BARS;
    reg  [9:0]    x;
    reg           de;
    wire [CW-1:0] r, g, b;
    integer errors = 0;
    integer xi, bar;
    reg [CW-1:0] er, eg, eb;

    vga_pattern #(.HACT(HACT), .BARS(BARS), .CW(CW)) dut (
        .x(x), .de(de), .r(r), .g(g), .b(b));

    initial begin
        $dumpfile("vga_pattern_tb.vcd");
        $dumpvars(0, vga_pattern_tb);
        // de=0 -> 黑
        de = 0; x = 100; #1;
        if (r!==0 || g!==0 || b!==0) begin errors=errors+1; $display("  消隐区非黑 r=%h g=%h b=%h", r,g,b); end
        // de=1 扫描全部可见列
        de = 1;
        for (xi = 0; xi < HACT; xi = xi + 1) begin
            x = xi[9:0]; #1;
            bar = xi / BARW; if (bar > 7) bar = 7;
            er = bar[2] ? {CW{1'b1}} : 0;
            eg = bar[1] ? {CW{1'b1}} : 0;
            eb = bar[0] ? {CW{1'b1}} : 0;
            if (r!==er || g!==eg || b!==eb) begin
                errors=errors+1;
                if (errors<6) $display("  x=%0d bar=%0d rgb=%h%h%h 期望=%h%h%h", xi, bar, r,g,b, er,eg,eb);
            end
        end
        if (errors==0) $display("[PASS] vga_pattern: 8 条标准彩条 + 消隐黑场，逐列颜色正确");
        else            $display("[FAIL] vga_pattern: %0d 处错误", errors);
        $finish;
    end
endmodule
