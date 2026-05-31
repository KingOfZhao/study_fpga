`timescale 1ns/1ps
module debounce_multi_tb;
    localparam N = 4, STABLE = 8;
    reg clk = 0, rst_n;
    reg  [N-1:0] din;
    wire [N-1:0] dout;
    integer errors = 0;
    integer i;

    debounce_multi #(.N(N), .STABLE(STABLE)) dut (.clk(clk), .rst_n(rst_n), .din(din), .dout(dout));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("debounce_multi_tb.vcd");
        $dumpvars(0, debounce_multi_tb);
        rst_n = 0; din = 0;
        @(negedge clk); rst_n = 1;

        // 路0：抖动后稳定为 1
        for (i = 0; i < 6; i = i + 1) begin
            din[0] = i[0]; @(negedge clk);   // 高频抖动
        end
        din[0] = 1;
        repeat (STABLE + 6) @(negedge clk);
        if (dout[0] !== 1'b1) begin errors = errors + 1; $display("  路0 未稳定为 1, dout=%b", dout); end

        // 路1：保持短暂的毛刺(<STABLE)不应改变输出
        din[1] = 1; repeat (STABLE/2) @(negedge clk);
        din[1] = 0; repeat (STABLE + 6) @(negedge clk);
        if (dout[1] !== 1'b0) begin errors = errors + 1; $display("  路1 毛刺被误接受, dout=%b", dout); end

        // 路2 与 路3 同时稳定置 1，互不影响
        din[2] = 1; din[3] = 1;
        repeat (STABLE + 6) @(negedge clk);
        if (dout[2] !== 1'b1 || dout[3] !== 1'b1) begin
            errors = errors + 1; $display("  路2/3 未稳定, dout=%b", dout);
        end

        if (errors == 0) $display("[PASS] debounce_multi: 多路独立消抖正确（接受稳定、滤除毛刺）");
        else             $display("[FAIL] debounce_multi: %0d 处错误", errors);
        $finish;
    end
endmodule
