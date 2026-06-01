# 26 · CRC-16 crc16

bit-serial CRC-16/CCITT-FALSE（多项式 0x1021，初值 0xFFFF）。

## 这一课学什么
- 更宽的 CRC（16 位）→ 更强的检错能力，常见于 Modbus/XMODEM/USB
- 多项式/初值/输入输出反转/异或值 是 CRC 变体的四个关键参数
- 用 "123456789" 的校验值 0x29B1 自校验

> 软件类比：和 CRC-8 同源，只是“校验和”更宽、碰撞更少。理解一个 CRC 变体，换参数就能实现一大票标准。

## 运行
```bash
make        # 对 "123456789" 校验 CRC=0x29B1
make wave
make clean
```

## 上板玩法
- Modbus-RTU、无线/串口协议帧校验的常用选择。

## 动手改
1. 改成 Modbus CRC-16（多项式 0x8005、输入输出反转），对照在线计算器。
2. 做并行版本提升吞吐。

## 对应真实开源项目
- 在线核对：[crccalc](https://crccalc.com/)；Modbus/XMODEM 规范文档；本仓 `intermediate/25_crc8` 是其窄位宽版本。
