`timescale 1ns/1ps
module sine_rom_tb;
    localparam AW = 6, DW = 8, DEPTH = 64;
    reg clk = 0;
    reg  [AW-1:0] addr;
    wire [DW-1:0] data;
    integer errors = 0;
    integer i;
    reg [DW-1:0] samp [0:DEPTH-1];

    sine_rom #(.AW(AW), .DW(DW)) dut (.clk(clk), .addr(addr), .data(data));
    always #5 clk = ~clk;

    task chk(input integer idx, input integer expv, input integer tol); begin
        if ((samp[idx] > expv && samp[idx]-expv > tol) ||
            (samp[idx] < expv && expv-samp[idx] > tol)) begin
            errors = errors + 1;
            $display("  样点[%0d]=%0d 期望≈%0d (tol %0d)", idx, samp[idx], expv, tol);
        end
    end endtask

    initial begin
        $dumpfile("sine_rom_tb.vcd");
        $dumpvars(0, sine_rom_tb);
        addr = 0;
        // 扫描整张表（同步读 1 拍延迟）
        for (i = 0; i < DEPTH; i = i + 1) begin
            addr = i[AW-1:0];
            @(posedge clk); #1;
            samp[i] = data;
        end
        // 关键点检查：0->~128, 16->~255, 32->~128, 48->~0
        chk(0, 128, 3);
        chk(16, 255, 3);
        chk(32, 128, 3);
        chk(48, 0, 3);
        // 第一象限单调上升
        for (i = 1; i <= 16; i = i + 1)
            if (samp[i] < samp[i-1]) begin
                errors = errors + 1;
                $display("  第一象限非单调 [%0d]=%0d [%0d]=%0d", i-1, samp[i-1], i, samp[i]);
            end
        if (errors == 0) $display("[PASS] sine_rom: 正弦表关键点与单调性正确");
        else             $display("[FAIL] sine_rom: %0d 处错误", errors);
        $finish;
    end
endmodule
