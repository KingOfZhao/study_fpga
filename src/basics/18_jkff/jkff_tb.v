`timescale 1ns/1ps
module jkff_tb;
    reg clk = 0, rst_n, j, k;
    wire q;
    integer errors = 0;
    reg model = 0;

    jkff dut (.clk(clk), .rst_n(rst_n), .j(j), .k(k), .q(q));
    always #5 clk = ~clk;

    integer i;
    initial begin
        $dumpfile("jkff_tb.vcd");
        $dumpvars(0, jkff_tb);
        rst_n = 0; j = 0; k = 0; model = 0;
        @(negedge clk); rst_n = 1;
        for (i = 0; i < 40; i = i + 1) begin
            j = $random; k = $random;
            @(posedge clk);
            case ({j, k})
                2'b00: model = model;
                2'b01: model = 1'b0;
                2'b10: model = 1'b1;
                default: model = ~model;
            endcase
            #1;
            if (q !== model) begin
                errors = errors + 1;
                $display("  MISMATCH i=%0d jk=%b%b q=%b model=%b", i, j, k, q, model);
            end
        end
        if (errors == 0) $display("[PASS] jkff: 保持/置位/复位/翻转 全部正确");
        else             $display("[FAIL] jkff: %0d 处错误", errors);
        $finish;
    end
endmodule
