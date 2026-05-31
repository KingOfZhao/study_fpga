// 自校验 testbench：I2C 读传感器 + UART 上报
// tb 内置一个"传感器"（I2C 从机行为模型），按地址应答并送出固定字节；
// 再用行为级 UART 接收器解码 tx_serial，校验：
//   1) I2C 地址被应答（ack_err=0）
//   2) UART 串口收到的字节 == 传感器返回值 == 顶层锁存的 sensor_byte
`timescale 1ns/1ps

module i2c_sensor_uart_tb;
    localparam integer DIV          = 4;
    localparam integer CLKS_PER_BIT = 8;
    localparam [6:0]   DEV_ADDR     = 7'h27;
    localparam [7:0]   SENSOR_DATA  = 8'hA5;

    reg clk = 0;
    reg rst_n;
    reg go;
    integer errors = 0;

    wire [7:0] sensor_byte;
    wire       busy, done, ack_err;
    wire       scl, sda_oe, tx_serial, tx_active;

    // —— 开漏总线建模 —— 
    wire sda;
    reg  s_sda_low = 1'b0;             // 从机拉低标志
    pullup (sda);                      // 总线上拉
    assign sda = sda_oe   ? 1'b0 : 1'bz;   // 主机开漏
    assign sda = s_sda_low ? 1'b0 : 1'bz;  // 从机开漏

    i2c_sensor_uart #(.DIV(DIV), .CLKS_PER_BIT(CLKS_PER_BIT), .DEV_ADDR(DEV_ADDR)) dut (
        .clk(clk), .rst_n(rst_n), .go(go),
        .sensor_byte(sensor_byte), .busy(busy), .done(done), .ack_err(ack_err),
        .scl(scl), .sda_oe(sda_oe), .sda_i(sda),
        .tx_serial(tx_serial), .tx_active(tx_active)
    );

    always #5 clk = ~clk;

    // —— I2C 从机（传感器）行为模型 ——
    integer i;
    reg [7:0] raddr;
    initial begin
        s_sda_low = 1'b0;
        forever begin
            @(negedge sda);                 // 候选 START：SDA 下降
            if (scl === 1'b1) begin         // 仅当 SCL 高时才是 START
                // 收 8 位（地址 + 读/写位），在 SCL 上升沿采样
                for (i = 0; i < 8; i = i + 1) begin
                    @(posedge scl); raddr[7-i] = sda;
                end
                // 应答：在紧接的 SCL 低期间拉低 SDA
                @(negedge scl);
                if (raddr[7:1] == DEV_ADDR) s_sda_low = 1'b1;
                @(posedge scl);             // 主机采样 ACK
                @(negedge scl); s_sda_low = 1'b0;
                // 若是读事务，送出 8 位数据（MSB 先），SCL 低时建立
                if (raddr[7:1] == DEV_ADDR && raddr[0] == 1'b1) begin
                    for (i = 0; i < 8; i = i + 1) begin
                        s_sda_low = (SENSOR_DATA[7-i] == 1'b0) ? 1'b1 : 1'b0;
                        @(posedge scl);     // 主机采样该位
                        @(negedge scl);     // 切换到下一位
                    end
                    s_sda_low = 1'b0;       // 释放，等主机 NACK + STOP
                end
            end
        end
    end

    // —— 行为级 UART 接收器：解码 tx_serial（8N1，LSB 先）——
    reg [7:0] uart_rx_byte;
    task uart_capture;
        integer k;
        begin
            @(negedge tx_serial);                 // 起始位
            repeat (CLKS_PER_BIT + CLKS_PER_BIT/2) @(posedge clk); // 到 bit0 中点
            for (k = 0; k < 8; k = k + 1) begin
                uart_rx_byte[k] = tx_serial;
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
        end
    endtask

    initial begin
        $dumpfile("i2c_sensor_uart_tb.vcd");
        $dumpvars(0, i2c_sensor_uart_tb);

        go    = 1'b0;
        rst_n = 1'b0;
        repeat (6) @(negedge clk);
        rst_n = 1'b1;
        repeat (4) @(negedge clk);

        // 发起一次"读 + 上报"
        go = 1'b1; @(negedge clk); go = 1'b0;

        // 并行：捕获 UART 输出字节
        uart_capture;

        // 等顶层 done
        begin : wait_done
            integer t;
            t = 0;
            while (done !== 1'b1 && t < 200000) begin @(posedge clk); t = t + 1; end
        end

        // —— 校验 ——
        if (ack_err !== 1'b0) begin
            errors = errors + 1;
            $display("[FAIL] I2C 地址未被应答 ack_err=%b", ack_err);
        end
        if (sensor_byte !== SENSOR_DATA) begin
            errors = errors + 1;
            $display("[FAIL] 顶层锁存字节=0x%02h（期望 0x%02h）", sensor_byte, SENSOR_DATA);
        end
        if (uart_rx_byte !== SENSOR_DATA) begin
            errors = errors + 1;
            $display("[FAIL] UART 收到字节=0x%02h（期望 0x%02h）", uart_rx_byte, SENSOR_DATA);
        end

        if (errors == 0)
            $display("[PASS] i2c_sensor_uart: I2C 读到 0x%02h 并经 UART 正确上报", SENSOR_DATA);
        else
            $display("[FAIL] i2c_sensor_uart: 共 %0d 处错误", errors);
        $finish;
    end

    initial begin
        #10_000_000;
        $display("[FAIL] 仿真超时");
        $finish;
    end
endmodule
