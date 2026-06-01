# 15 · 带 FIFO 的 UART 发送 uart_tx_fifo

写入字节进 FIFO，模块自动逐字节通过 UART 发出，解耦产生速率与发送速率。

## 这一课学什么
- 用 FIFO 做“生产者-消费者”缓冲：写入很快、发送很慢，FIFO 吸收差速
- 满则反压（不再接收写入），空则停止发送
- 组合现有 `uart_tx` + `sync_fifo` 的系统级设计

> 软件类比：经典的有界队列/生产者-消费者——上游往队列里塞数据，下游按自己节奏取出发送，队列满时上游需等待（背压）。

## 运行
```bash
make        # 批量写入字节，校验经 UART 顺序无丢失发出
make wave
make clean
```

## 上板玩法
- 日志/数据上报：突发产生的字节排队后平稳发出，避免丢数。

## 动手改
1. 加“FIFO 几乎满”水位告警。
2. 接收端也加 FIFO，做成全双工带缓冲串口。

## 对应真实开源项目
- 带 FIFO 的 UART 是 16550 类 UART 的基本特征；参考 [alexforencich/verilog-uart](https://github.com/alexforencich/verilog-uart)。
