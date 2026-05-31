`timescale 1ns/1ps
module stepper_position_tb;
    localparam SW = 16;
    reg clk = 0, rst_n, go, dir;
    reg  [SW-1:0] target;
    wire [3:0] phase;
    wire [SW-1:0] cur;
    wire busy;
    integer errors = 0;
    reg [3:0] seq [0:3];

    stepper_position #(.SW(SW)) dut (
        .clk(clk), .rst_n(rst_n), .go(go), .dir(dir), .target(target),
        .phase(phase), .cur(cur), .busy(busy));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("stepper_position_tb.vcd");
        $dumpvars(0, stepper_position_tb);
        seq[0]=4'b0001; seq[1]=4'b0010; seq[2]=4'b0100; seq[3]=4'b1000;
        rst_n=0; go=0; dir=1; target=10;
        repeat (2) @(negedge clk); rst_n=1;
        @(negedge clk); go=1; @(negedge clk); go=0;
        wait (busy);                 // 进入运行
        wait (!busy);                // 到位
        @(negedge clk);
        if (cur !== target) begin errors=errors+1; $display("  到位 cur=%0d 期望=%0d", cur, target); end
        if (phase !== seq[target % 4]) begin
            errors=errors+1; $display("  终相 phase=%b 期望=%b", phase, seq[target%4]);
        end
        if (errors==0) $display("[PASS] stepper_position: 定位到 %0d 步，步进相序终态正确", target);
        else            $display("[FAIL] stepper_position: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] stepper_position: 超时"); $finish; end
endmodule
