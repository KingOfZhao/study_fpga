# 04 · UART 回显器 uart_echo

`uart_rx + sync_fifo + uart_tx`：收到字节缓冲后逐字节回发。

## 这一课学什么
- 系统级组合：把三个原子模块（收/缓冲/发）接成一条数据通路
- FIFO 解耦收发速率，避免接收快于发送时丢数
- 回显是验证整条串口链路的最直接方式

> 软件类比：像一个 echo 服务——读入请求、入队、再原样写回。FIFO 就是请求队列，收发就是 read/write。

## 运行
```bash
make        # 发送多字节，校验原样回显
make wave
make clean
```

## 上板玩法
- 接 USB-TTL 与电脑串口助手对话：打什么字符就回显什么，验证波特率/接线正确。

## 动手改
1. 回显前做大小写转换/加 1（看到“处理”发生）。
2. 加带 CRC 的帧（直接看 `projects/15_uart_crc_frame`）。

## 对应真实开源项目
- 串口回显是经典上手项目；UART 实现参考 [nandland](https://github.com/nandland/nandland)、[alexforencich/verilog-uart](https://github.com/alexforencich/verilog-uart)。
