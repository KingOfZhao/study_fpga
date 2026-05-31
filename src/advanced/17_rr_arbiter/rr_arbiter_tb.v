`timescale 1ns/1ps
module rr_arbiter_tb;
    localparam N = 4;
    reg clk = 0, rst_n;
    reg  [N-1:0] req;
    wire [N-1:0] grant;
    integer errors = 0;
    integer i, cnt [0:N-1];
    integer ones;

    rr_arbiter #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .req(req), .grant(grant));
    always #5 clk = ~clk;

    function integer popcount(input [N-1:0] v);
        integer t, c; begin c=0; for(t=0;t<N;t=t+1) c=c+v[t]; popcount=c; end
    endfunction

    initial begin
        $dumpfile("rr_arbiter_tb.vcd");
        $dumpvars(0, rr_arbiter_tb);
        rst_n=0; req=0;
        for (i=0;i<N;i=i+1) cnt[i]=0;
        repeat (2) @(negedge clk); rst_n=1;

        // 1) 任意时刻最多授权一个；req=0 时不授权
        req = 4'b0000; @(negedge clk);
        if (grant !== 0) begin errors=errors+1; $display("  req=0 时 grant=%b", grant); end

        // 2) 全部请求时应公平轮转：统计 16 拍每路被授权次数应接近
        req = 4'b1111;
        for (i=0;i<16;i=i+1) begin
            @(negedge clk);
            ones = popcount(grant);
            if (ones != 1) begin errors=errors+1; $display("  grant 非单热=%b", grant); end
            if (grant[0]) cnt[0]=cnt[0]+1;
            if (grant[1]) cnt[1]=cnt[1]+1;
            if (grant[2]) cnt[2]=cnt[2]+1;
            if (grant[3]) cnt[3]=cnt[3]+1;
        end
        for (i=0;i<N;i=i+1)
            if (cnt[i] != 4) begin errors=errors+1; $display("  通道%0d 被授权%0d次(期望4)", i, cnt[i]); end

        // 3) 部分请求：只在请求集合内授权
        req = 4'b1010; @(negedge clk);
        if (!(grant==4'b0010 || grant==4'b1000)) begin errors=errors+1; $display("  req=1010 grant=%b", grant); end

        if (errors==0) $display("[PASS] rr_arbiter: 单热授权 + 满请求公平轮转(各4次) + 仅在请求内授权");
        else            $display("[FAIL] rr_arbiter: %0d 处错误", errors);
        $finish;
    end
endmodule
