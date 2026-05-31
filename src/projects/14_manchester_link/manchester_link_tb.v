`timescale 1ns/1ps
module manchester_link_tb;
    reg clk = 0, rst_n, start;
    reg  [7:0] tx_data;
    wire       tx_done, rx_valid, code_err;
    wire [7:0] rx_data;
    integer errors = 0, i;
    reg [7:0] vec [0:3];

    manchester_link dut (.clk(clk), .rst_n(rst_n), .start(start), .tx_data(tx_data),
        .tx_done(tx_done), .rx_data(rx_data), .rx_valid(rx_valid), .code_err(code_err));
    always #5 clk = ~clk;

    always @(posedge clk) if (rst_n && code_err) begin errors=errors+1; $display("  编码错误标志被置位"); end

    task send(input [7:0] d);
        begin
            tx_data = d; @(negedge clk); start=1; @(negedge clk); start=0;
            wait (rx_valid); @(negedge clk);
            if (rx_data !== d) begin errors=errors+1; $display("  收=%h 期望=%h", rx_data, d); end
            else $display("  链路传输 %h 正确", rx_data);
            repeat (4) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("manchester_link_tb.vcd");
        $dumpvars(0, manchester_link_tb);
        vec[0]=8'h55; vec[1]=8'hA3; vec[2]=8'h00; vec[3]=8'hFF;
        rst_n=0; start=0; tx_data=0;
        repeat (2) @(negedge clk); rst_n=1;
        for (i = 0; i < 4; i = i + 1) send(vec[i]);
        if (errors==0) $display("[PASS] manchester_link: 4 字节经曼彻斯特编解码无误且编码合法");
        else            $display("[FAIL] manchester_link: %0d 处错误", errors);
        $finish;
    end
    initial begin #500000; $display("[FAIL] manchester_link: 超时"); $finish; end
endmodule
