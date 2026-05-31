`timescale 1ns/1ps
module freq_meter_seg_tb;
    localparam GATE = 200, W = 16;
    reg clk = 0, rst_n, sig;
    wire [W-1:0] freq;
    wire done;
    wire [7:0] seg_h, seg_t, seg_o;
    integer errors = 0;
    integer recon;

    freq_meter_seg #(.GATE(GATE), .W(W)) dut (
        .clk(clk), .rst_n(rst_n), .sig(sig), .freq(freq), .done(done),
        .seg_h(seg_h), .seg_t(seg_t), .seg_o(seg_o));

    always #5 clk = ~clk;
    // 待测信号：周期 10 拍(每 5 拍翻转) -> GATE=200 拍内约 20 个上升沿
    always #25 sig = ~sig;

    // 段码 -> 数字 反查
    function integer seg2dig(input [7:0] s);
        begin
            case (s)
                8'hC0: seg2dig=0; 8'hF9: seg2dig=1; 8'hA4: seg2dig=2; 8'hB0: seg2dig=3;
                8'h99: seg2dig=4; 8'h92: seg2dig=5; 8'h82: seg2dig=6; 8'hF8: seg2dig=7;
                8'h80: seg2dig=8; 8'h90: seg2dig=9; default: seg2dig=-1;
            endcase
        end
    endfunction

    initial begin
        $dumpfile("freq_meter_seg_tb.vcd");
        $dumpvars(0, freq_meter_seg_tb);
        rst_n=0; sig=0;
        repeat (3) @(negedge clk); rst_n=1;
        @(posedge done); #1;
        // 1) 频率合理范围
        if (freq < 38 || freq > 42) begin
            errors=errors+1; $display("  测得 freq=%0d 超出预期 [38,42]", freq);
        end
        // 2) 数码管显示 == freq 的十进制各位
        recon = seg2dig(seg_h)*100 + seg2dig(seg_t)*10 + seg2dig(seg_o);
        if (recon !== freq) begin
            errors=errors+1; $display("  数码管重建=%0d 与 freq=%0d 不符 (seg %h %h %h)", recon, freq, seg_h, seg_t, seg_o);
        end else
            $display("  freq=%0d 数码管显示 %0d%0d%0d", freq, seg2dig(seg_h), seg2dig(seg_t), seg2dig(seg_o));
        if (errors==0) $display("[PASS] freq_meter_seg: 频率测量 + BCD + 数码管显示链路正确");
        else            $display("[FAIL] freq_meter_seg: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] freq_meter_seg: 超时"); $finish; end
endmodule
