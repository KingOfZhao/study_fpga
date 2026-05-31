`timescale 1ns/1ps
module decoder3_8_tb;
    reg        en;
    reg  [2:0] addr;
    wire [7:0] y;
    integer errors = 0;
    integer i;
    reg [7:0] exp;

    decoder3_8 dut (.en(en), .addr(addr), .y(y));

    initial begin
        $dumpfile("decoder3_8_tb.vcd");
        $dumpvars(0, decoder3_8_tb);
        // en=0：输出应全 0
        en = 1'b0; addr = 3'd3; #1;
        if (y !== 8'd0) begin errors = errors + 1; $display("  MISMATCH en=0 y=%b", y); end
        // en=1：one-hot
        en = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            addr = i[2:0]; #1;
            exp = (8'd1 << i);
            if (y !== exp) begin errors = errors + 1; $display("  MISMATCH addr=%0d y=%b exp=%b", i, y, exp); end
        end
        if (errors == 0) $display("[PASS] decoder3_8: 使能与 8 路 one-hot 全部正确");
        else             $display("[FAIL] decoder3_8: %0d 处错误", errors);
        $finish;
    end
endmodule
