# 22 · I2C 主机(多字节写) i2c_master_write

START → 地址+写位 → ACK → 连续写 N 字节(各等 ACK) → STOP。

## 这一课学什么
- I2C 时序：START/STOP 条件、地址帧、每字节后的 ACK/NACK
- **开漏总线**：线“与”逻辑，靠上拉电阻拉高，设备只能拉低（仿真用 oe/i 抽象，上板需 IOBUF）
- 多字节连续写（寄存器地址 + 数据流）

> 软件类比：像调用一个传感器/EEPROM 的“写寄存器”API，底层是一帧帧带应答的串行事务。难点全在“开漏 + 应答”这套电气/握手规则。

## 运行
```bash
make        # tb 内置简易从机捕获并应答，校验写入字节
make wave
make clean
```

## 上板玩法
- 配置 I2C 传感器/EEPROM/RTC；上板务必加上拉电阻并用 inout 三态（见 `hardening/i2c_iobuf_top.v`）。

## 动手改
1. 加多字节读（含重复 START）。
2. 做超阈报警应用（直接看 `projects/16_i2c_alarm`）。

## 对应真实开源项目
- I2C 规范见 NXP UM10204；实现参考 [alexforencich/verilog-i2c](https://github.com/alexforencich/verilog-i2c)；三态处理见本仓 `docs/08`。
