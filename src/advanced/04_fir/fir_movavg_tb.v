// fir_movavg 自校验 testbench
// 喂一串样本，用独立的参考模型（滑动窗口求和取平均）逐拍比对输出。
`timescale 1ns/1ps

module fir_movavg_tb;
    localparam DW = 8;
    localparam N  = 4;
    localparam NS = 16;          // 样本个数

    reg            clk = 1'b0, rst_n;
    reg            valid_in;
    reg  [DW-1:0]  x;
    wire           valid_out;
    wire [DW-1:0]  y;

    fir_movavg #(.DW(DW), .N(N)) dut (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x(x),
        .valid_out(valid_out), .y(y)
    );

    always #5 clk = ~clk;

    // 参考模型
    integer win [0:N-1];
    integer k, j, s, exp_y, errors = 0;
    reg [DW-1:0] seq [0:NS-1];

    initial begin
        // 一段测试样本（含阶跃与尖峰，便于观察平滑效果）
        seq[0]=8'd0;  seq[1]=8'd0;   seq[2]=8'd100; seq[3]=8'd100;
        seq[4]=8'd100;seq[5]=8'd100; seq[6]=8'd200; seq[7]=8'd0;
        seq[8]=8'd40; seq[9]=8'd80;  seq[10]=8'd120;seq[11]=8'd160;
        seq[12]=8'd255;seq[13]=8'd255;seq[14]=8'd1; seq[15]=8'd7;
    end

    initial begin
        $dumpfile("fir_movavg_tb.vcd");
        $dumpvars(0, fir_movavg_tb);

        for (j = 0; j < N; j = j + 1) win[j] = 0;
        valid_in = 1'b0; x = 8'd0;
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        for (k = 0; k < NS; k = k + 1) begin
            @(negedge clk);
            x        = seq[k];
            valid_in = 1'b1;
            @(posedge clk);          // 此沿采样 -> y/valid_out 在沿后更新
            #1;
            // 更新参考窗口：压入新样本
            for (j = N-1; j > 0; j = j - 1) win[j] = win[j-1];
            win[0] = seq[k];
            s = 0;
            for (j = 0; j < N; j = j + 1) s = s + win[j];
            exp_y = s / N;

            if (!valid_out) begin
                errors = errors + 1;
                $display("[FAIL] 样本 %0d：valid_out 应为 1", k);
            end
            if (y !== exp_y[DW-1:0]) begin
                errors = errors + 1;
                $display("[FAIL] 样本 %0d：x=%0d y=%0d 期望=%0d", k, seq[k], y, exp_y);
            end else
                $display("[ OK ] x=%0d -> 平均=%0d", seq[k], y);
        end

        @(negedge clk); valid_in = 1'b0;
        @(posedge clk); #1;
        if (valid_out !== 1'b0) begin
            errors = errors + 1;
            $display("[FAIL] valid_in=0 后 valid_out 应为 0");
        end

        if (errors == 0)
            $display("[PASS] fir_movavg: 所有样本移动平均正确");
        else begin
            $display("[FAIL] fir_movavg: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
