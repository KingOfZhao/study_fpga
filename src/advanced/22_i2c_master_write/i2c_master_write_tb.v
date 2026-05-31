`timescale 1ns/1ps
module i2c_master_write_tb;
    localparam DIV = 4, NBYTES = 3;
    reg clk = 0, rst_n, start;
    reg  [6:0] dev_addr;
    reg  [NBYTES*8-1:0] wdata;
    wire done, ack_err, scl, sda_oe;
    wire sda_line;
    reg  slave_oe = 0;
    integer errors = 0;

    assign sda_line = ~(sda_oe | slave_oe);   // 开漏线与

    i2c_master_write #(.DIV(DIV), .NBYTES(NBYTES)) dut (
        .clk(clk), .rst_n(rst_n), .start(start), .dev_addr(dev_addr),
        .wdata(wdata), .done(done), .ack_err(ack_err),
        .scl(scl), .sda_oe(sda_oe), .sda_i(sda_line));
    always #5 clk = ~clk;

    // ---- 简易 I2C 从机模型（捕获 + 应答）----
    integer re = 0;             // 事务内 SCL 上升沿计数
    reg in_xact = 0;
    reg [7:0] rxbyte = 0;
    reg [7:0] cap [0:NBYTES];   // cap[0]=地址字节, cap[1..]=数据
    integer ncap = 0;
    reg sda_q;

    // START / STOP 检测
    always @(sda_line or scl) begin
        if (scl) begin
            if (sda_q==1'b1 && sda_line==1'b0) begin   // 下降 = START
                in_xact = 1; re = 0; ncap = 0; rxbyte = 0;
            end
            if (sda_q==1'b0 && sda_line==1'b1) begin   // 上升 = STOP
                in_xact = 0;
            end
        end
        sda_q = sda_line;
    end

    // 采样：SCL 上升沿
    always @(posedge scl) begin
        if (in_xact) begin
            re = re + 1;
            if (re % 9 == 0) begin
                cap[ncap] = rxbyte;   // 第 9 个时钟=ACK，落库一个字节
                ncap = ncap + 1;
            end else begin
                rxbyte = {rxbyte[6:0], sda_line};
            end
        end
    end

    // 应答：在每个 ACK bit 拉低 SDA
    always @(negedge scl) begin
        if (in_xact) begin
            if (re % 9 == 8)      slave_oe <= 1'b1;   // 8 个数据位后进入 ACK 窗
            else if (re % 9 == 0) slave_oe <= 1'b0;   // ACK 结束释放
        end
    end

    integer i;
    initial begin
        $dumpfile("i2c_master_write_tb.vcd");
        $dumpvars(0, i2c_master_write_tb);
        rst_n=0; start=0; dev_addr=7'h2A; wdata={8'h11, 8'h22, 8'h33}; // 高->低: byte2=11,1=22,0=33
        repeat (3) @(negedge clk); rst_n=1;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait (done); @(negedge clk);
        // 校验
        if (ack_err) begin errors=errors+1; $display("  ack_err 置位"); end
        if (ncap != NBYTES+1) begin errors=errors+1; $display("  捕获字节数=%0d 期望=%0d", ncap, NBYTES+1); end
        if (cap[0] !== {dev_addr,1'b0}) begin errors=errors+1; $display("  地址字节=%h 期望=%h", cap[0], {dev_addr,1'b0}); end
        for (i = 0; i < NBYTES; i = i + 1)
            if (cap[i+1] !== wdata[i*8 +: 8]) begin
                errors=errors+1; $display("  数据%0d=%h 期望=%h", i, cap[i+1], wdata[i*8 +: 8]);
            end
        if (errors==0) $display("[PASS] i2c_master_write: 地址+3 字节写时序/ACK 正确，从机捕获一致");
        else            $display("[FAIL] i2c_master_write: %0d 处错误", errors);
        $finish;
    end

    initial begin #500000; $display("[FAIL] i2c_master_write: 超时"); $finish; end
endmodule
