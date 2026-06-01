# 12 · 异步 FIFO async_fifo

跨时钟域（CDC）的经典方案：读/写指针用**格雷码**经**两级同步器**传到对方时钟域。

## 这一课学什么
- 为什么不能直接把多位指针送到另一个时钟域：多位同时变会采到中间乱码
- 解法：指针转**格雷码**（一次只变 1 位）→ 过两级同步器 → 比较产生 full/empty
- 这是多时钟系统数据缓冲的工业标准做法

> 软件类比：像两个不同节奏的线程通过一个环形缓冲通信。但软件有锁/原子操作，硬件没有——只能靠“一次只变 1 位 + 多级采样”这种物理级技巧保证安全。

## 运行
```bash
make        # 写 100MHz、读异步较慢，写 12 个读 12 个校验顺序
make wave
make clean
```

## 上板玩法
- ADC↔处理、不同接口速率之间的数据缓冲都靠它跨时钟。

## 动手改
1. 把读写时钟比改成更极端（如 7:3），观察 full/empty 行为。
2. 加几乎满/几乎空标志（对照 `advanced/24_fifo_progfull`）。

## 对应真实开源项目
- 经典权威：Clifford Cummings《Simulation and Synthesis Techniques for Asynchronous FIFO Design》(SNUG 2002)；CDC 综述见本仓 `docs/08_hardware_and_synthesis.md`。
