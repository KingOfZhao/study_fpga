`timescale 1ns/1ps
module edge_detector_tb;
    reg clk = 0, rst_n, sig;
    wire rise, fall, any_edge;
    integer errors = 0;
    integer rcount = 0, fcount = 0;

    edge_detector dut (.clk(clk), .rst_n(rst_n), .sig(sig),
                       .rise(rise), .fall(fall), .any_edge(any_edge));
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rise) rcount = rcount + 1;
        if (fall) fcount = fcount + 1;
        if (rise && fall) begin errors = errors + 1; $display("  rise&fall 同时为 1"); end
        if (any_edge !== (rise | fall)) begin errors = errors + 1; $display("  any_edge 不一致"); end
    end

    initial begin
        $dumpfile("edge_detector_tb.vcd");
        $dumpvars(0, edge_detector_tb);
        rst_n = 0; sig = 0;
        @(negedge clk); rst_n = 1;
        // 制造 3 个上升沿 + 3 个下降沿
        repeat (3) begin
            @(negedge clk); sig = 1; repeat (2) @(negedge clk);
            sig = 0; repeat (2) @(negedge clk);
        end
        repeat (3) @(negedge clk);
        if (rcount != 3 || fcount != 3) begin
            errors = errors + 1;
            $display("  rise=%0d fall=%0d (期望 3/3)", rcount, fcount);
        end
        if (errors == 0) $display("[PASS] edge_detector: 上升/下降沿各 3 次，脉冲单拍");
        else             $display("[FAIL] edge_detector: %0d 处错误", errors);
        $finish;
    end
endmodule
