# 24 · 可编程满标志 FIFO fifo_progfull

同步 FIFO，输出 `count` 及可编程的 `prog_full`/`prog_empty` 标志，用于流控。

## 这一课学什么
- 除了 full/empty，再加“几乎满/几乎空”水位线（阈值可配）
- 应用：提前反压（不等真满就告警），避免溢出/欠载
- count 直接反映占用深度

> 软件类比：像有界队列的“高/低水位”——队列到 80% 就提醒生产者减速、到 20% 就提醒消费者别太快。这是流控的常见手段。

## 运行
```bash
make        # 读写到不同深度，校验 count 与可编程标志
make wave
make clean
```

## 上板玩法
- DMA/数据流的流控点：用 prog_full 提前发反压信号。

## 动手改
1. 阈值改成运行时可配置（寄存器写入）。
2. 升级成异步 FIFO（对照 `intermediate/12_async_fifo`）。

## 对应真实开源项目
- 可编程标志是 Xilinx/Intel FIFO IP 的标准特性；参考各家 FIFO Generator 文档。
