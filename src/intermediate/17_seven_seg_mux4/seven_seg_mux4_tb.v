`timescale 1ns/1ps
module seven_seg_mux4_tb;
    localparam REFRESH = 4;
    reg clk = 0, rst_n;
    reg  [3:0] d0, d1, d2, d3;
    wire [3:0] an;
    wire [6:0] seg;
    integer errors = 0;
    integer i;
    integer seen = 0;   // bitmask of digits观察到

    seven_seg_mux4 #(.REFRESH(REFRESH)) dut (
        .clk(clk), .rst_n(rst_n), .d0(d0), .d1(d1), .d2(d2), .d3(d3),
        .an(an), .seg(seg));
    always #5 clk = ~clk;

    function [6:0] decode(input [3:0] v);
        case (v)
            4'd0: decode = 7'b1111110; 4'd1: decode = 7'b0110000;
            4'd2: decode = 7'b1101101; 4'd3: decode = 7'b1111001;
            4'd4: decode = 7'b0110011; 4'd5: decode = 7'b1011011;
            4'd6: decode = 7'b1011111; 4'd7: decode = 7'b1110000;
            4'd8: decode = 7'b1111111; 4'd9: decode = 7'b1111011;
            default: decode = 7'b0000000;
        endcase
    endfunction

    reg [3:0] exp_digit;
    reg [6:0] exp_seg;
    initial begin
        $dumpfile("seven_seg_mux4_tb.vcd");
        $dumpvars(0, seven_seg_mux4_tb);
        rst_n = 0; d0 = 1; d1 = 2; d2 = 3; d3 = 4;
        @(negedge clk); rst_n = 1;
        // 扫描足够多周期，覆盖 4 个数位
        for (i = 0; i < REFRESH*4*3; i = i + 1) begin
            @(posedge clk); #1;
            // 当前选中位（an 中为 0 的位）
            case (an)
                4'b1110: begin exp_digit = d0; seen = seen | 1; end
                4'b1101: begin exp_digit = d1; seen = seen | 2; end
                4'b1011: begin exp_digit = d2; seen = seen | 4; end
                4'b0111: begin exp_digit = d3; seen = seen | 8; end
                default: begin errors = errors + 1; $display("  非法 an=%b", an); end
            endcase
            exp_seg = ~decode(exp_digit);
            if (seg !== exp_seg) begin
                errors = errors + 1;
                $display("  an=%b seg=%b 期望=%b", an, seg, exp_seg);
            end
        end
        if (seen !== 15) begin errors = errors + 1; $display("  未覆盖全部 4 位 seen=%0d", seen); end
        if (errors == 0) $display("[PASS] seven_seg_mux4: 4 位轮流点亮且段码正确");
        else             $display("[FAIL] seven_seg_mux4: %0d 处错误", errors);
        $finish;
    end
endmodule
