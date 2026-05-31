# 03 · 同步 FIFO

FIFO（先进先出缓冲）是 FPGA 里最常用的数据结构之一：跨模块缓冲、流水线弹性、速率匹配都靠它。

## 这一课学什么
- **片上存储**：用 `reg [WIDTH-1:0] mem [0:DEPTH-1]` 描述一块 RAM
- **环形指针**：`wr_ptr/rd_ptr` 用 `$clog2(DEPTH)` 位宽，加 1 自动回绕
- **满/空判定**：用 `count` 计数最直观；进阶可用指针多一位法
- **同时读写**：`count` 在同读同写时保持不变（注意边界）
- **输出寄存延迟**：`rd_data` 在 `rd_en` 后**一拍**才有效

> 软件类比：就是一个固定容量的队列（`Queue`），但它是真实的硬件 RAM + 两个指针，读写可以在同一个时钟周期并行发生。

## 运行
```bash
make            # 写满 16 个 -> 验证 full -> 顺序读出验证 FIFO 顺序 -> 验证 empty
make wave       # 观察 wr_ptr/rd_ptr/count/full/empty
make clean
```

## 动手改
1. 把它接到 UART 之间，做一个带缓冲的串口收发。
2. 改成**异步 FIFO**（读写不同时钟），学习格雷码指针 + 双触发器同步（进阶难点）。
3. 加 `almost_full/almost_empty` 水位标志。
