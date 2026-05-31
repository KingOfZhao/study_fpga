`timescale 1ns/1ps
module parity_tb;
    localparam W = 8;
    reg  [W-1:0] data;
    wire even_par, odd_par;
    integer errors = 0;
    integer i, k, cnt;

    parity #(.W(W)) dut (.data(data), .even_par(even_par), .odd_par(odd_par));

    initial begin
        $dumpfile("parity_tb.vcd");
        $dumpvars(0, parity_tb);
        for (i = 0; i < 256; i = i + 1) begin
            data = i[W-1:0];
            #1;
            cnt = 0;
            for (k = 0; k < W; k = k + 1) cnt = cnt + data[k];
            if (even_par !== cnt[0] || odd_par !== ~cnt[0]) begin
                errors = errors + 1;
                $display("  MISMATCH data=%b cnt=%0d even=%b odd=%b", data, cnt, even_par, odd_par);
            end
        end
        if (errors == 0) $display("[PASS] parity: 256 种数据奇偶校验全部正确");
        else             $display("[FAIL] parity: %0d 处错误", errors);
        $finish;
    end
endmodule
