`timescale 1ns/1ps
module mac_tb;
    localparam W = 8, ACC = 32;
    reg clk = 0, rst_n, clr, valid;
    reg  signed [W-1:0] a, b;
    wire signed [ACC-1:0] acc;
    integer errors = 0;
    integer i;
    reg signed [ACC-1:0] model;

    mac #(.W(W), .ACC(ACC)) dut (.clk(clk), .rst_n(rst_n), .clr(clr), .valid(valid),
                                 .a(a), .b(b), .acc(acc));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mac_tb.vcd");
        $dumpvars(0, mac_tb);
        rst_n = 0; clr = 0; valid = 0; a = 0; b = 0; model = 0;
        @(negedge clk); rst_n = 1;
        @(negedge clk); clr = 1; @(negedge clk); clr = 0; model = 0;
        // 累加 20 组随机乘积
        for (i = 0; i < 20; i = i + 1) begin
            a = $random; b = $random;
            valid = 1;
            model = model + a * b;
            @(posedge clk); #1;
            valid = 0;
            @(negedge clk);
            if (acc !== model) begin
                errors = errors + 1;
                $display("  第%0d步 acc=%0d 期望=%0d", i, acc, model);
            end
        end
        // clr 验证
        @(negedge clk); clr = 1; @(negedge clk); clr = 0;
        if (acc !== 0) begin errors = errors + 1; $display("  clr 后 acc=%0d", acc); end
        if (errors == 0) $display("[PASS] mac: 20 组乘累加与模型一致，clr 正确");
        else             $display("[FAIL] mac: %0d 处错误", errors);
        $finish;
    end
endmodule
