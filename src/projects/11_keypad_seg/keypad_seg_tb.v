`timescale 1ns/1ps
module keypad_seg_tb;
    localparam TR = 1, TC = 1;          // 目标按键 (行1,列1) -> key=5
    reg clk = 0, rst_n;
    wire [3:0] row;
    wire [3:0] key_latched;
    wire       key_valid;
    wire [7:0] seg;
    reg  [3:0] col;
    integer errors = 0;

    keypad_seg dut (.clk(clk), .rst_n(rst_n), .col(col), .row(row),
        .key_latched(key_latched), .key_valid(key_valid), .seg(seg));
    always #5 clk = ~clk;

    // 当扫描到目标行时，把目标列拉低，模拟该键被按下
    always @(*) begin
        if (row == ~(4'b0001 << TR)) col = ~(4'b0001 << TC);
        else                          col = 4'b1111;
    end

    initial begin
        $dumpfile("keypad_seg_tb.vcd");
        $dumpvars(0, keypad_seg_tb);
        rst_n=0;
        repeat (2) @(negedge clk); rst_n=1;
        // 等扫描捕获按键
        wait (key_valid);
        repeat (3) @(negedge clk);
        if (key_latched !== (TR*4 + TC)) begin
            errors=errors+1; $display("  捕获键码=%0d 期望=%0d", key_latched, TR*4+TC);
        end
        if (seg !== 8'h92) begin   // 数字 5 的段码
            errors=errors+1; $display("  seg=%h 期望=92(数字5)", seg);
        end
        if (errors==0) $display("[PASS] keypad_seg: 扫描捕获键码 5 并数码管正确显示");
        else            $display("[FAIL] keypad_seg: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] keypad_seg: 超时 (未捕获按键)"); $finish; end
endmodule
