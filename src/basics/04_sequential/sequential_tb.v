// dff + shift_reg 自校验 testbench
`timescale 1ns/1ps

module sequential_tb;
    reg        clk = 0;
    reg        rst;
    integer    errors = 0;
    integer    i;

    // --- DFF ---
    reg        d;
    wire       q;
    dff u_dff (.clk(clk), .rst(rst), .d(d), .q(q));

    // --- 移位寄存器 ---
    localparam N = 8;
    reg            sin;
    wire           sout;
    wire [N-1:0]   pout;
    reg  [N-1:0]   pattern;
    shift_reg #(.N(N)) u_sr (.clk(clk), .rst(rst), .sin(sin), .serial_out(sout), .pout(pout));

    always #5 clk = ~clk;

    task check1(input got, input exp, input [255:0] name);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("[FAIL] %0s: got=%b exp=%b", name, got, exp);
            end else $display("[ OK ] %0s = %b", name, got);
        end
    endtask

    task check8(input [7:0] got, input [7:0] exp, input [255:0] name);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("[FAIL] %0s: got=%b exp=%b", name, got, exp);
            end else $display("[ OK ] %0s = %b", name, got);
        end
    endtask

    initial begin
        $dumpfile("sequential_tb.vcd");
        $dumpvars(0, sequential_tb);

        // 复位
        rst = 1'b1; d = 1'b0; sin = 1'b0;
        @(posedge clk); #1;
        check1(q, 1'b0, "dff after reset");
        check8(pout, 8'h00, "shift_reg after reset");

        rst = 1'b0;

        // DFF：q 应在一个时钟后跟随 d
        d = 1'b1; @(posedge clk); #1; check1(q, 1'b1, "dff captures 1");
        d = 1'b0; @(posedge clk); #1; check1(q, 1'b0, "dff captures 0");

        // 移位寄存器：MSB 优先送入 pattern，8 拍后并行输出应等于 pattern
        // 在负沿改变 sin，保证上升沿采样到稳定值（避免在时钟沿改输入引发竞争）
        pattern = 8'b1011_0010;
        for (i = 0; i < N; i = i + 1) begin
            @(negedge clk);
            sin = pattern[N-1-i];
        end
        @(posedge clk);   // 让最后一位被采样
        #1;
        check8(pout, pattern, "shift_reg serial->parallel");
        check1(sout, pattern[N-1], "shift_reg serial_out = MSB");

        if (errors == 0)
            $display("[PASS] sequential: all assertions passed");
        else begin
            $display("[FAIL] sequential: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
