# 16 · Skid Buffer skid_buffer

valid/ready 握手流水寄存器，支持背压不丢数。AXI-Stream 打拍/时序收敛常用。

## 这一课学什么
- 直接给握手信号打一拍会丢数据——skid buffer 用一个“备用寄存器”兜住下游忙时的那一拍
- 实现 **全吞吐**（每拍都能传）的同时切断 valid/ready 的组合路径（改善时序）
- 是流水线设计的关键拼图

> 软件类比：像有界缓冲里的“1 格余量”——下游突然说“我忙”，上游已经发出的那个数据有地方暂存，不会丢，下游恢复后再交付。

## 运行
```bash
make        # 制造背压，校验数据顺序无丢失/无重复
make wave
make clean
```

## 上板玩法
- 长组合路径打拍以提频；AXI-Stream 节点间插入改善时序。

## 动手改
1. 串两级 skid，观察延迟与吞吐。
2. 对比“直接寄存 valid/ready”为何会丢数或降吞吐。

## 对应真实开源项目
- 权威讲解：[ZipCPU 的 Skid Buffer 教程](https://zipcpu.com/blog/2019/05/22/skidbuffer.html)；AXI-Stream 规范。
