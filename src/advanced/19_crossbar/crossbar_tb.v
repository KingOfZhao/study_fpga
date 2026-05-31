`timescale 1ns/1ps
module crossbar_tb;
    localparam N = 4, W = 8, SW = 2;
    reg  [N*W-1:0]    din;
    reg  [N*SW-1:0]   sel;
    wire [N*W-1:0]    dout;
    integer errors = 0;
    integer o, t;
    reg [SW-1:0] si;

    crossbar #(.N(N), .W(W)) dut (.din(din), .sel(sel), .dout(dout));

    task check;
        begin
            #1;
            for (o = 0; o < N; o = o + 1) begin
                si = sel[o*SW +: SW];
                if (dout[o*W +: W] !== din[si*W +: W]) begin
                    errors = errors + 1;
                    $display("  输出%0d sel=%0d dout=%h 期望=%h", o, si, dout[o*W +: W], din[si*W +: W]);
                end
            end
        end
    endtask

    initial begin
        $dumpfile("crossbar_tb.vcd");
        $dumpvars(0, crossbar_tb);
        din = {8'hD4, 8'hC3, 8'hB2, 8'hA1};   // 输入0=A1,1=B2,2=C3,3=D4
        sel = {2'd0, 2'd1, 2'd2, 2'd3};       // 反序
        check;
        sel = {2'd3, 2'd3, 2'd3, 2'd3};       // 全选输入3
        check;
        sel = {2'd2, 2'd0, 2'd1, 2'd3};       // 任意置换
        check;
        // 随机若干次
        for (t = 0; t < 20; t = t + 1) begin
            din = {$random, $random};
            sel = $random;
            check;
        end
        if (errors == 0) $display("[PASS] crossbar: 4x4 交叉开关路由正确(含随机)");
        else             $display("[FAIL] crossbar: %0d 处错误", errors);
        $finish;
    end
endmodule
