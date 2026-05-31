// mux4to1 + decoder2to4 自校验 testbench
`timescale 1ns/1ps

module mux_decoder_tb;
    // --- MUX 信号 ---
    reg  [3:0] d0, d1, d2, d3;
    reg  [1:0] msel;
    wire [3:0] my;

    // --- Decoder 信号 ---
    reg        en;
    reg  [1:0] da;
    wire [3:0] dy;

    integer    errors = 0;
    integer    i;

    mux4to1     #(.WIDTH(4)) u_mux (.d0(d0), .d1(d1), .d2(d2), .d3(d3), .sel(msel), .y(my));
    decoder2to4              u_dec (.en(en), .a(da), .y(dy));

    task expect4(input [3:0] got, input [3:0] exp, input [255:0] name);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("[FAIL] %0s: got=%b exp=%b", name, got, exp);
            end else
                $display("[ OK ] %0s = %b", name, got);
        end
    endtask

    initial begin
        $dumpfile("mux_decoder_tb.vcd");
        $dumpvars(0, mux_decoder_tb);

        // 给四路数据不同的值，便于区分选中的是哪一路
        d0 = 4'hA; d1 = 4'hB; d2 = 4'hC; d3 = 4'hD;
        msel = 2'b00; #5; expect4(my, 4'hA, "mux sel=0 -> d0");
        msel = 2'b01; #5; expect4(my, 4'hB, "mux sel=1 -> d1");
        msel = 2'b10; #5; expect4(my, 4'hC, "mux sel=2 -> d2");
        msel = 2'b11; #5; expect4(my, 4'hD, "mux sel=3 -> d3");

        // 译码器：使能后输出 one-hot
        en = 1'b0; da = 2'b00; #5; expect4(dy, 4'b0000, "decoder disabled");
        en = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            da = i[1:0]; #5;
            expect4(dy, 4'b0001 << i, "decoder one-hot");
        end

        if (errors == 0)
            $display("[PASS] mux_decoder: all assertions passed");
        else begin
            $display("[FAIL] mux_decoder: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
