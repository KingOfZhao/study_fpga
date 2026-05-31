`timescale 1ns/1ps
module vga_box_tb;
    localparam BS = 2;
    reg clk = 0, rst_n;
    wire hsync, vsync, active, rgb;
    wire [9:0] px, py, bx;
    integer errors = 0;
    integer white_cnt, frames;
    reg vsync_d;
    integer bx_seen [0:3];

    vga_box #(.BS(BS)) dut (
        .clk(clk), .rst_n(rst_n), .hsync(hsync), .vsync(vsync),
        .active(active), .px(px), .py(py), .bx(bx), .rgb(rgb));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("vga_box_tb.vcd");
        $dumpvars(0, vga_box_tb);
        rst_n=0; vsync_d=1; white_cnt=0; frames=0;
        repeat (2) @(negedge clk); rst_n=1;
        // 观察 4 帧：每帧统计白色像素数；记录每帧 bx
        while (frames < 4) begin
            @(negedge clk);
            if (rgb) white_cnt = white_cnt + 1;
            vsync_d <= vsync;
            if (vsync_d && !vsync) begin
                // 一帧结束，校验白色像素数 == BS*BS
                if (white_cnt !== BS*BS) begin
                    errors=errors+1; $display("  帧%0d 白像素=%0d 期望=%0d", frames, white_cnt, BS*BS);
                end else $display("  帧%0d: bx=%0d 白像素=%0d", frames, bx, white_cnt);
                bx_seen[frames] = bx;
                white_cnt = 0;
                frames = frames + 1;
            end
        end
        // 方块应逐帧右移（相邻帧 bx 不同）
        if (bx_seen[1] == bx_seen[0]) begin errors=errors+1; $display("  方块未移动 bx 帧0=%0d 帧1=%0d", bx_seen[0], bx_seen[1]); end
        if (errors==0) $display("[PASS] vga_box: 每帧渲染 %0d 个白像素且方块逐帧移动", BS*BS);
        else            $display("[FAIL] vga_box: %0d 处错误", errors);
        $finish;
    end
    initial begin #500000; $display("[FAIL] vga_box: 超时"); $finish; end
endmodule
