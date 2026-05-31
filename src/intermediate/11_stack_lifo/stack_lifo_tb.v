`timescale 1ns/1ps
module stack_lifo_tb;
    localparam W = 8, DEPTH = 8;
    reg clk = 0, rst_n, push, pop;
    reg  [W-1:0] din;
    wire [W-1:0] dout;
    wire full, empty;
    integer errors = 0;
    integer i;

    stack_lifo #(.W(W), .DEPTH(DEPTH)) dut (
        .clk(clk), .rst_n(rst_n), .push(push), .pop(pop),
        .din(din), .dout(dout), .full(full), .empty(empty));
    always #5 clk = ~clk;

    task do_push(input [W-1:0] v); begin
        din = v; push = 1; pop = 0; @(posedge clk); #1; push = 0;
    end endtask
    task do_pop; begin
        pop = 1; push = 0; @(posedge clk); #1; pop = 0;
    end endtask

    initial begin
        $dumpfile("stack_lifo_tb.vcd");
        $dumpvars(0, stack_lifo_tb);
        rst_n = 0; push = 0; pop = 0; din = 0;
        @(negedge clk); rst_n = 1; #1;
        if (!empty) begin errors = errors + 1; $display("  复位后应 empty"); end
        // 压入 1..8
        for (i = 1; i <= DEPTH; i = i + 1) do_push(i[W-1:0]);
        if (!full) begin errors = errors + 1; $display("  压满后应 full"); end
        // LIFO：弹出应为 8,7,...,1
        for (i = DEPTH; i >= 1; i = i - 1) begin
            if (dout !== i[W-1:0]) begin
                errors = errors + 1;
                $display("  栈顶=%0d 期望=%0d", dout, i);
            end
            do_pop;
        end
        if (!empty) begin errors = errors + 1; $display("  全部弹出后应 empty"); end
        if (errors == 0) $display("[PASS] stack_lifo: 压/弹满栈 LIFO 顺序与标志正确");
        else             $display("[FAIL] stack_lifo: %0d 处错误", errors);
        $finish;
    end
endmodule
