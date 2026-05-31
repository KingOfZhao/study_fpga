`timescale 1ns/1ps
module skid_buffer_tb;
    localparam W = 8;
    reg clk = 0, rst_n;
    reg  s_valid; reg [W-1:0] s_data; wire s_ready;
    wire m_valid; wire [W-1:0] m_data; reg m_ready;
    integer errors = 0;
    integer i;

    // 参考队列
    reg [W-1:0] q [0:255];
    integer wq = 0, rq = 0;
    integer sent = 0;

    skid_buffer #(.W(W)) dut (.clk(clk), .rst_n(rst_n),
        .s_valid(s_valid), .s_data(s_data), .s_ready(s_ready),
        .m_valid(m_valid), .m_data(m_data), .m_ready(m_ready));
    always #5 clk = ~clk;

    // 上游：随机产生数据
    always @(posedge clk) begin
        if (rst_n && s_valid && s_ready) begin
            q[wq] = s_data; wq = wq + 1;   // 记录被接收的数据
        end
    end
    // 下游：随机背压并校验输出顺序
    always @(posedge clk) begin
        if (rst_n && m_valid && m_ready) begin
            if (m_data !== q[rq]) begin
                errors = errors + 1;
                $display("  输出#%0d=%h 期望=%h", rq, m_data, q[rq]);
            end
            rq = rq + 1;
        end
    end

    initial begin
        $dumpfile("skid_buffer_tb.vcd");
        $dumpvars(0, skid_buffer_tb);
        rst_n=0; s_valid=0; s_data=0; m_ready=0;
        repeat (2) @(negedge clk); rst_n=1;
        for (i = 0; i < 400; i = i + 1) begin
            @(negedge clk);
            // 随机驱动 s_valid / m_ready
            if (sent < 100) begin
                s_valid = ($random % 3 != 0);   // ~2/3 概率有效
                s_data  = sent[7:0] ^ 8'hA5;
                if (s_valid && s_ready) sent = sent + 1;
            end else s_valid = 0;
            m_ready = ($random % 2 == 0);
        end
        // 排空
        s_valid = 0; m_ready = 1;
        repeat (20) @(negedge clk);
        if (errors == 0 && rq == 100 && wq == 100)
            $display("[PASS] skid_buffer: 100 个数据经随机背压无丢失、顺序正确 (收=%0d 发=%0d)", wq, rq);
        else
            $display("[FAIL] skid_buffer: errors=%0d 收=%0d 发=%0d", errors, wq, rq);
        $finish;
    end

    initial begin #100000; $display("[FAIL] skid_buffer: 超时"); $finish; end
endmodule
