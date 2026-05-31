// ram_sp 自校验 testbench —— 写入全部地址，再读回比对（考虑 1 拍读延迟）
`timescale 1ns/1ps

module ram_sp_tb;
    localparam DW = 8;
    localparam AW = 4;
    localparam DEPTH = (1 << AW);

    reg            clk = 1'b0;
    reg            we;
    reg  [AW-1:0]  addr;
    reg  [DW-1:0]  din;
    wire [DW-1:0]  dout;

    integer i, errors = 0;
    reg [DW-1:0] expected [0:DEPTH-1];

    ram_sp #(.DW(DW), .AW(AW)) dut (
        .clk(clk), .we(we), .addr(addr), .din(din), .dout(dout)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("ram_sp_tb.vcd");
        $dumpvars(0, ram_sp_tb);

        we = 1'b0; addr = {AW{1'b0}}; din = {DW{1'b0}};
        @(negedge clk);

        // —— 写入阶段：mem[i] = 3*i + 7 ——
        we = 1'b1;
        for (i = 0; i < DEPTH; i = i + 1) begin
            addr = i[AW-1:0];
            din  = (3*i + 7);
            expected[i] = (3*i + 7);
            @(negedge clk);
        end
        we = 1'b0;

        // —— 读回阶段：地址在沿被寄存，dout 在该沿之后有效 ——
        for (i = 0; i < DEPTH; i = i + 1) begin
            addr = i[AW-1:0];
            @(posedge clk);     // 此沿把 mem[addr] 寄进 dout
            #1;                 // 等非阻塞赋值生效后采样
            if (dout !== expected[i]) begin
                errors = errors + 1;
                $display("[FAIL] addr=%0d dout=%0d 期望=%0d", i, dout, expected[i]);
            end else
                $display("[ OK ] addr=%0d -> %0d", i, dout);
        end

        if (errors == 0)
            $display("[PASS] ram_sp: 全部 %0d 个地址写读一致", DEPTH);
        else begin
            $display("[FAIL] ram_sp: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
