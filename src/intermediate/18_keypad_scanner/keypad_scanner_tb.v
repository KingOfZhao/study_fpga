`timescale 1ns/1ps
module keypad_scanner_tb;
    reg clk = 0, rst_n;
    reg  [1:0] pr, pc;          // 按下的行/列
    wire [3:0] row;
    reg  [3:0] col;
    wire [3:0] key;
    wire       key_valid;
    integer errors = 0;
    integer i;
    reg got; reg [3:0] gotkey;

    keypad_scanner dut (.clk(clk), .rst_n(rst_n), .col(col),
                        .row(row), .key(key), .key_valid(key_valid));
    always #5 clk = ~clk;

    // 键盘模型：当扫描到按下的那一行时，对应列拉低
    always @(*) begin
        if (row == ~(4'b0001 << pr)) col = ~(4'b0001 << pc);
        else                         col = 4'b1111;
    end

    always @(posedge clk) if (key_valid) begin got = 1; gotkey = key; end

    task test_key(input [1:0] r, input [1:0] c);
        begin
            pr = r; pc = c; got = 0;
            repeat (20) @(posedge clk);
            if (!got) begin errors = errors + 1; $display("  键(%0d,%0d) 未检出", r, c); end
            else if (gotkey !== {r, c}) begin
                errors = errors + 1;
                $display("  键(%0d,%0d) 检出码=%0d 期望=%0d", r, c, gotkey, {r,c});
            end
        end
    endtask

    initial begin
        $dumpfile("keypad_scanner_tb.vcd");
        $dumpvars(0, keypad_scanner_tb);
        rst_n = 0; pr = 0; pc = 0; col = 4'b1111; got = 0;
        @(negedge clk); rst_n = 1;
        test_key(2'd0, 2'd0);
        test_key(2'd1, 2'd3);
        test_key(2'd2, 2'd2);
        test_key(2'd3, 2'd1);
        if (errors == 0) $display("[PASS] keypad_scanner: 4 个按键定位正确");
        else             $display("[FAIL] keypad_scanner: %0d 处错误", errors);
        $finish;
    end
endmodule
