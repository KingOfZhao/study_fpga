`timescale 1ns/1ps
module dual_port_ram_tb;
    localparam W = 8, AW = 4, DEPTH = 16;
    reg clk = 0, we;
    reg  [AW-1:0] waddr, raddr;
    reg  [W-1:0]  wdata;
    wire [W-1:0]  rdata;
    integer errors = 0;
    integer i;
    reg [W-1:0] ref_mem [0:DEPTH-1];

    dual_port_ram #(.W(W), .AW(AW)) dut (
        .clk(clk), .we(we), .waddr(waddr), .wdata(wdata), .raddr(raddr), .rdata(rdata));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dual_port_ram_tb.vcd");
        $dumpvars(0, dual_port_ram_tb);
        we = 0; waddr = 0; raddr = 0; wdata = 0;
        // 写入全部地址
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge clk);
            we = 1; waddr = i[AW-1:0]; wdata = (i*7 + 3) & 8'hFF;
            ref_mem[i] = (i*7 + 3) & 8'hFF;
        end
        @(negedge clk); we = 0;
        // 逐地址同步读回（1 拍延迟）
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge clk); raddr = i[AW-1:0];
            @(posedge clk); #1;       // 等同步读输出
            if (rdata !== ref_mem[i]) begin
                errors = errors + 1;
                $display("  addr=%0d rdata=%h exp=%h", i, rdata, ref_mem[i]);
            end
        end
        if (errors == 0) $display("[PASS] dual_port_ram: 16 地址写入/同步读回全部正确");
        else             $display("[FAIL] dual_port_ram: %0d 处错误", errors);
        $finish;
    end
endmodule
