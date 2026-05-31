`timescale 1ns/1ps
module updown_counter_tb;
    localparam W = 8;
    reg clk = 0, rst_n, en, up_down;
    wire [W-1:0] cnt;
    integer errors = 0;
    integer i;
    reg [W-1:0] model;

    updown_counter #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .en(en), .up_down(up_down), .cnt(cnt));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("updown_counter_tb.vcd");
        $dumpvars(0, updown_counter_tb);
        rst_n = 0; en = 0; up_down = 1; model = 0;
        @(negedge clk); rst_n = 1;
        for (i = 0; i < 60; i = i + 1) begin
            en = $random; up_down = $random;
            @(posedge clk);
            if (en) model = up_down ? (model + 1) : (model - 1);
            #1;
            if (cnt !== model) begin
                errors = errors + 1;
                $display("  MISMATCH i=%0d en=%b ud=%b cnt=%h model=%h", i, en, up_down, cnt, model);
            end
        end
        if (errors == 0) $display("[PASS] updown_counter: 加/减/保持/回绕正确");
        else             $display("[FAIL] updown_counter: %0d 处错误", errors);
        $finish;
    end
endmodule
