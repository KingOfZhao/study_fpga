`timescale 1ns/1ps
module uart_crc_frame_tb;
    localparam CPB = 8;
    reg clk = 0, rst_n, send;
    reg  [7:0] data_in;
    wire       tx_serial;
    wire [7:0] data_out;
    wire       frame_valid, crc_ok;
    integer errors = 0, i;
    reg [7:0] vec [0:3];

    // 内部回环：tx_serial -> rx_serial
    uart_crc_frame #(.CLKS_PER_BIT(CPB)) dut (
        .clk(clk), .rst_n(rst_n), .send(send), .data_in(data_in),
        .tx_serial(tx_serial), .rx_serial(tx_serial),
        .data_out(data_out), .frame_valid(frame_valid), .crc_ok(crc_ok));
    always #5 clk = ~clk;

    task send_frame(input [7:0] d);
        begin
            @(negedge clk); data_in=d; send=1; @(negedge clk); send=0;
            wait (frame_valid); @(negedge clk);
            if (data_out !== d) begin errors=errors+1; $display("  收数据=%h 期望=%h", data_out, d); end
            else if (!crc_ok)   begin errors=errors+1; $display("  数据 %h 的 CRC 校验失败", d); end
            else                $display("  帧 %h 接收且 CRC 正确", d);
            repeat (4) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("uart_crc_frame_tb.vcd");
        $dumpvars(0, uart_crc_frame_tb);
        vec[0]=8'h3C; vec[1]=8'hA5; vec[2]=8'h00; vec[3]=8'hFF;
        rst_n=0; send=0; data_in=0;
        repeat (3) @(negedge clk); rst_n=1;
        for (i = 0; i < 4; i = i + 1) send_frame(vec[i]);
        if (errors==0) $display("[PASS] uart_crc_frame: 4 帧经 UART+CRC8 收发数据与校验均正确");
        else            $display("[FAIL] uart_crc_frame: %0d 处错误", errors);
        $finish;
    end
    initial begin #4000000; $display("[FAIL] uart_crc_frame: 超时"); $finish; end
endmodule
