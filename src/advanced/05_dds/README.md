# 05 · DDS / NCO dds

直接数字频率合成：相位累加器每拍累加频率字 `fword`，取相位高位查正弦表输出。

## 这一课学什么
- **相位累加器**：每拍 `phase += fword`，溢出回绕 = 一个完整周期
- 输出频率 = `fclk × fword / 2^N`（改 fword 即改频率，分辨率极高）
- 相位高位作 ROM 地址查正弦表 → 输出波形（对照 `intermediate/14_sine_rom`）

> 软件类比：像用一个不断累加并对 2^N 取模的“相位计数器”驱动查表——累加步长决定转速。这是软件无线电(SDR)里最常见的信号源思路。

## 运行
```bash
make        # 校验不同 fword 下的输出频率/相位推进
make wave
make clean
```

## 上板玩法
- 任意频率正弦/方波发生器、FSK/PSK 调制、音频音调生成。

## 动手改
1. 加相位偏置端做相位调制(PM)。
2. 串口实时改 fword（直接看 `projects/19_dds_uart_ctrl`）。

## 对应真实开源项目
- DDS/NCO 是 SDR 核心；参考 Xilinx DDS Compiler 文档、[GNURadio](https://github.com/gnuradio/gnuradio) 的 NCO，以及本仓 `projects/19_dds_uart_ctrl`。
