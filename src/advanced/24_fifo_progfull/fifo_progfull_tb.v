`timescale 1ns/1ps
module fifo_progfull_tb;
    localparam DW=8, AW=4, DEPTH=(1<<AW), AFULL=12, AEMPTY=2;
    reg clk=0, rst_n, wr, rd;
    reg  [DW-1:0] din;
    wire [DW-1:0] dout;
    wire full, empty, prog_full, prog_empty;
    wire [AW:0] count;
    integer errors = 0;
    integer i;

    fifo_progfull #(.DW(DW),.AW(AW),.AFULL(AFULL),.AEMPTY(AEMPTY)) dut (
        .clk(clk),.rst_n(rst_n),.wr(wr),.din(din),.rd(rd),.dout(dout),
        .full(full),.empty(empty),.prog_full(prog_full),.prog_empty(prog_empty),.count(count));
    always #5 clk = ~clk;

    task wr1(input [DW-1:0] d); begin @(negedge clk); wr=1; din=d; @(negedge clk); wr=0; end endtask
    task rd1;                   begin @(negedge clk); rd=1;        @(negedge clk); rd=0; end endtask

    initial begin
        $dumpfile("fifo_progfull_tb.vcd");
        $dumpvars(0, fifo_progfull_tb);
        rst_n=0; wr=0; rd=0; din=0;
        repeat (2) @(negedge clk); rst_n=1; @(negedge clk);
        if (!empty || count!==0 || !prog_empty) begin errors=errors+1; $display("  复位后 empty=%b cnt=%0d pe=%b", empty,count,prog_empty); end

        // 逐个写满，检查 count / prog_full / full 阈值
        for (i = 1; i <= DEPTH; i = i + 1) begin
            wr1(i[DW-1:0]);
            if (count !== i[AW:0]) begin errors=errors+1; $display("  写%0d 后 count=%0d", i, count); end
            if ((count >= AFULL) && !prog_full) begin errors=errors+1; $display("  count=%0d 应 prog_full", count); end
            if ((count <  AFULL) &&  prog_full) begin errors=errors+1; $display("  count=%0d 不应 prog_full", count); end
        end
        if (!full) begin errors=errors+1; $display("  写满后 full 未置位 count=%0d", count); end

        // 读空，检查 prog_empty 阈值与数据顺序(FWFT)
        for (i = 1; i <= DEPTH; i = i + 1) begin
            if (dout !== i[DW-1:0]) begin errors=errors+1; $display("  读出=%h 期望=%h", dout, i[DW-1:0]); end
            rd1;
            if ((count <= AEMPTY) && !prog_empty) begin errors=errors+1; $display("  count=%0d 应 prog_empty", count); end
        end
        if (!empty) begin errors=errors+1; $display("  读空后 empty 未置位"); end

        if (errors==0) $display("[PASS] fifo_progfull: count/full/empty/prog_full/prog_empty 阈值与数据顺序均正确");
        else            $display("[FAIL] fifo_progfull: %0d 处错误", errors);
        $finish;
    end
    initial begin #200000; $display("[FAIL] fifo_progfull: 超时"); $finish; end
endmodule
