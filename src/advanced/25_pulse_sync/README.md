# 25 · 跨时钟域脉冲同步器 pulse_sync

toggle + 2FF + 边沿检测，把源域单拍脉冲安全传到异步目的域。CDC 经典电路。

## 这一课学什么
- 单拍脉冲直接过两级同步器可能丢失（脉冲太窄）→ 先把脉冲转成 **电平翻转(toggle)**
- 目的域用两级同步器采 toggle，再边沿检测还原成单拍脉冲
- 限制：源脉冲间隔必须够宽（让目的域采得到）

> 软件类比：像跨线程传一个“一次性事件”——不能直接传瞬时信号，而是翻转一个标志位，对方检测到标志变化即知“事件发生过一次”。

## 运行
```bash
make        # 源域发脉冲，校验目的域还原出等量脉冲
make wave
make clean
```

## 上板玩法
- 中断/事件跨时钟域通知；配合异步 FIFO 处理跨时钟数据。

## 动手改
1. 加“源脉冲过快”的丢失检测/反压。
2. 多 bit 数据跨时钟改用握手或异步 FIFO（对照 `intermediate/12_async_fifo`）。

## 对应真实开源项目
- CDC 同步器是工业必修；权威参考 Clifford Cummings 的 CDC 论文，综述见本仓 `docs/08_hardware_and_synthesis.md`、`hardening/synchronizer.v`。
