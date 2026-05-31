`timescale 1ns/1ps
module shift_register_tb;
    localparam W = 8;
    reg clk = 0, rst_n, sin_l, sin_r;
    reg [1:0] mode;
    reg [W-1:0] din;
    wire [W-1:0] q;
    integer errors = 0;
    integer i;
    reg [W-1:0] model;

    shift_register #(.W(W)) dut (.clk(clk), .rst_n(rst_n), .mode(mode),
                                 .sin_l(sin_l), .sin_r(sin_r), .din(din), .q(q));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("shift_register_tb.vcd");
        $dumpvars(0, shift_register_tb);
        rst_n = 0; mode = 2'b00; sin_l = 0; sin_r = 0; din = 0; model = 0;
        @(negedge clk); rst_n = 1;
        for (i = 0; i < 80; i = i + 1) begin
            mode = $random; sin_l = $random; sin_r = $random; din = $random;
            @(posedge clk);
            case (mode)
                2'b00: model = model;
                2'b01: model = {sin_r, model[W-1:1]};
                2'b10: model = {model[W-2:0], sin_l};
                default: model = din;
            endcase
            #1;
            if (q !== model) begin
                errors = errors + 1;
                $display("  MISMATCH i=%0d mode=%b q=%h model=%h", i, mode, q, model);
            end
        end
        if (errors == 0) $display("[PASS] shift_register: 装载/左移/右移/保持全部正确");
        else             $display("[FAIL] shift_register: %0d 处错误", errors);
        $finish;
    end
endmodule
