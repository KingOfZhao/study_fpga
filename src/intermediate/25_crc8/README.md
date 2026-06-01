# 25 · CRC-8 crc8

bit-serial CRC-8（多项式 0x07，初值 0x00），数据完整性校验的基础。

## 这一课学什么
- CRC = 把数据当多项式对生成多项式取模，余数即校验码
- bit-serial 实现：本质就是一个带反馈异或的移位寄存器（LFSR 思想）
- 用标准串 "123456789" 的校验值 0xF4 自校验

> 软件类比：像对数据算一个比奇偶校验强得多的“哈希/校验和”——能检出多位错误和突发错误。算法虽有数学背景，硬件实现却只是移位 + 异或。

## 运行
```bash
make        # 对 "123456789" 校验 CRC=0xF4
make wave
make clean
```

## 上板玩法
- 串口/SPI/存储帧的完整性校验；可串进 UART 帧（见 `projects/15_uart_crc_frame`）。

## 动手改
1. 换多项式/初值，对比校验结果。
2. 改并行 CRC（一拍处理一字节），对比 bit-serial 的吞吐。

## 对应真实开源项目
- CRC 计算器/查表参考 [crccalc](https://crccalc.com/)；并行 CRC 推导见 Easics CRC 工具；帧校验实战见本仓 `projects/15_uart_crc_frame`。
