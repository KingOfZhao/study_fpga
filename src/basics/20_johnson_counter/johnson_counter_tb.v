`timescale 1ns/1ps
module johnson_counter_tb;
    localparam N = 4;
    reg clk = 0, rst_n;
    wire [N-1:0] q;
    integer errors = 0;
    integer i;
    reg [N-1:0] expq;

    johnson_counter #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .q(q));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("johnson_counter_tb.vcd");
        $dumpvars(0, johnson_counter_tb);
        rst_n = 0; @(negedge clk); rst_n = 1; #1;
        expq = 0;
        // 期望序列：0000,0001,0011,0111,1111,1110,1100,1000,0000...
        for (i = 0; i < 2*N*2; i = i + 1) begin
            @(posedge clk); #1;
            expq = {expq[N-2:0], ~expq[N-1]};
            if (q !== expq) begin
                errors = errors + 1;
                $display("  MISMATCH i=%0d q=%b exp=%b", i, q, expq);
            end
        end
        if (errors == 0) $display("[PASS] johnson_counter: 2N 状态扭环序列正确");
        else             $display("[FAIL] johnson_counter: %0d 处错误", errors);
        $finish;
    end
endmodule
