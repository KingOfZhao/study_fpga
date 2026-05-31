`timescale 1ns/1ps
module prio_arbiter_tb;
    localparam N = 8;
    reg  [N-1:0] req;
    wire [N-1:0] grant;
    wire         valid;
    integer errors = 0;
    integer i, k, lowest;

    prio_arbiter #(.N(N)) dut (.req(req), .grant(grant), .valid(valid));

    initial begin
        $dumpfile("prio_arbiter_tb.vcd");
        $dumpvars(0, prio_arbiter_tb);
        // 穷举所有 256 种请求组合
        for (i = 0; i < (1<<N); i = i + 1) begin
            req = i[N-1:0]; #1;
            if (i == 0) begin
                if (valid !== 1'b0 || grant !== 0) begin
                    errors=errors+1; $display("  req=0 grant=%b valid=%b", grant, valid);
                end
            end else begin
                // 期望最低置位
                lowest = -1;
                for (k = 0; k < N; k = k + 1)
                    if (lowest < 0 && req[k]) lowest = k;
                if (grant !== ({{(N-1){1'b0}},1'b1} << lowest) || valid !== 1'b1) begin
                    errors=errors+1;
                    if (errors<6) $display("  req=%b grant=%b 期望最低位=%0d", req, grant, lowest);
                end
            end
        end
        if (errors==0) $display("[PASS] prio_arbiter: 穷举 256 种请求，固定优先(最低索引)授权正确");
        else            $display("[FAIL] prio_arbiter: %0d 处错误", errors);
        $finish;
    end
endmodule
