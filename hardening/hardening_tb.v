`timescale 1ns/1ps
module hardening_tb;
    reg clk=0, rst_n, arst_n, async_in;
    wire sync_out, srst_n;
    integer errors=0;

    synchronizer #(.STAGES(2)) u_sync (.clk(clk), .rst_n(rst_n), .async_in(async_in), .sync_out(sync_out));
    reset_sync  #(.STAGES(2)) u_rs   (.clk(clk), .arst_n(arst_n), .srst_n(srst_n));

    // I2C 三态 wrapper
    reg scl_oe, sda_oe;
    wire sda_i, scl, sda;
    pullup(scl); pullup(sda);                 // 模拟外部上拉
    i2c_iobuf_top u_io (.scl_oe(scl_oe), .sda_oe(sda_oe), .sda_i(sda_i), .scl(scl), .sda(sda));

    always #5 clk=~clk;

    initial begin
        rst_n=0; arst_n=0; async_in=0; scl_oe=0; sda_oe=0;
        repeat(3) @(negedge clk); rst_n=1; arst_n=1;

        // 1) 同步器：输入拉高后，经 2 拍出现在 sync_out
        async_in=1; @(negedge clk);
        if (sync_out!==1'b0) begin errors=errors+1; $display("  同步器第1拍不应已出现"); end
        @(negedge clk);
        if (sync_out!==1'b1) begin errors=errors+1; $display("  同步器2拍后应为1, 实=%b", sync_out); end

        // 2) 复位同步器：异步拉低立即复位；释放后需若干拍才回到1
        arst_n=0; #1;
        if (srst_n!==1'b0) begin errors=errors+1; $display("  复位异步置位应立即为0"); end
        @(negedge clk); arst_n=1;
        @(negedge clk); @(negedge clk);
        if (srst_n!==1'b1) begin errors=errors+1; $display("  复位同步释放后应为1, 实=%b", srst_n); end

        // 3) I2C 三态：oe=0 时总线被上拉为1；oe=1 时被拉低为0
        sda_oe=0; #1;
        if (sda_i!==1'b1) begin errors=errors+1; $display("  开漏空闲应被上拉为1, 实=%b", sda_i); end
        sda_oe=1; #1;
        if (sda_i!==1'b0) begin errors=errors+1; $display("  开漏使能应拉低为0, 实=%b", sda_i); end

        if (errors==0) $display("[PASS] hardening: 同步器/复位同步器/I2C三态 上板加固模块全部正确");
        else           $display("[FAIL] hardening: %0d 处错误", errors);
        $finish;
    end
endmodule
