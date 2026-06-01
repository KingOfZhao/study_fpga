# 23 · 曼彻斯特编码器 manchester_enc

把字节串行编码，每位用两个 chip（`bit→{bit, ~bit}`），自带时钟信息。

## 这一课学什么
- 曼彻斯特编码：每个数据位都有一次跳变 → 接收端可从数据里恢复时钟
- 1 位变 2 chip，带宽翻倍换来“自同步”
- 用于以太网(10M)、RFID、红外等无独立时钟线的链路

> 软件类比：像一种“自带分隔符”的序列化——每个符号内部都有跳变，接收方据此切分，不需要额外的时钟信号同步。

## 运行
```bash
make        # 校验每个数据位编码成正确的两 chip
make wave
make clean
```

## 上板玩法
- 单线/无时钟链路的数据发送端；接收端配 `intermediate/24_manchester_dec`。

## 动手改
1. 切换 IEEE 与 G.E.Thomas 两种约定（跳变方向相反）。
2. 接成完整链路（直接看 `projects/14_manchester_link`）。

## 对应真实开源项目
- 曼彻斯特编码见于 10BASE-T 以太网、RFID(ISO14443)；链路实战见本仓 `projects/14_manchester_link`。
