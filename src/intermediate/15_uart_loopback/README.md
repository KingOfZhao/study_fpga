# 15 · UART 自环 uart_loopback

把已有的 `uart_tx` + `uart_rx` 组合成收发链路，TX 直接接回 RX。

## 这一课学什么
- **模块复用**：用现成的发送/接收模块拼系统，而不是重写
- 自环（loopback）是验证串口收发闭环的标准手段
- 波特率分频参数要两端一致

> 软件类比：像把一个序列化器和反序列化器接在一起，验证 `decode(encode(x)) == x`。这里 encode/decode 是真实的串行波形收发。

## 运行
```bash
make        # 连发 4 字节，校验自环收回一致
make wave
make clean
```

## 上板玩法
- 板上 TX→RX 短接做自测；或接 USB-TTL 与电脑串口助手对发。

## 动手改
1. 加 FIFO 缓冲（对照 `advanced/15_uart_tx_fifo`）。
2. 做成回显器：收到什么就发回什么（直接看 `projects/04_uart_echo`）。

## 对应真实开源项目
- UART 教学经典：[nandland/UART](https://github.com/nandland/nandland)、[Obijuan/open-fpga-verilog-tutorial](https://github.com/Obijuan/open-fpga-verilog-tutorial) 的串口章节。
