# 02 · SPI 主机（Mode 0）

SPI 是连接 ADC/DAC、Flash、传感器最常见的高速同步串行总线。本例实现一个 **Mode 0** 主机。

## 协议（Mode 0：CPOL=0, CPHA=0）
- `SCLK` 空闲为低
- **上升沿采样** `MISO`，**下降沿切换** `MOSI`
- MSB 优先，`CS_N` 低有效，一次传输 8 位
- `SCLK` 频率 = `clk / (2 * CLK_DIV)`

## 这一课学什么
- 用 FSM + 分频器生成同步串行时钟与数据
- 收发**同时进行**（全双工）：移出 `MOSI` 的同时移入 `MISO`
- `start/busy/done` 握手接口设计——可复用到其他外设

> 软件类比：相当于你调用过的 `spi.transfer(byte)`——但这里你亲手实现了时钟边沿、采样时刻和移位逻辑。

## 运行
```bash
make            # MISO 回环接 MOSI，验证 rx_data == tx_data（0xA5/0x3C/0xFF/0x01）
make wave       # 观察 cs_n/sclk/mosi/miso 的相位关系（重点看采样沿）
make clean
```

## 动手改
1. 增加 `cpol/cpha` 参数支持 4 种 SPI 模式。
2. 支持连续多字节传输（CS 保持低，连续 N 个字节）。
3. 接一个真实的 SPI 从机模型（如 ADC），验证读回数据。
