# 16 · SPI 从机 spi_slave

模式 0 SPI 从机，用系统时钟**过采样** sclk/cs_n/mosi（而非把外部 sclk 当时钟）。

## 这一课学什么
- FPGA 推荐做法：不把外部串行时钟直接当时钟用，而是**过采样 + 边沿检测**
- 模式 0：sclk 上升沿采样 MOSI、下降沿更新 MISO
- 全双工：收发同时进行，移位寄存器边进边出

> 软件类比：像不依赖外部时钟、而是高频轮询引脚状态并检测变化的驱动写法——更安全，避免“外部时钟”带来的时序约束噩梦。

## 运行
```bash
make        # tb 内置 SPI 主机模型，三次全双工传输校验收发一致
make wave
make clean
```

## 上板玩法
- 作为 SPI 外设（如配置寄存器、DAC 从机）；外部 sclk/cs 务必先过同步器。

## 动手改
1. 支持其它 3 种 SPI 模式（对照 `advanced/21_spi_master_modes`）。
2. 接成主从链路（直接看 `projects/17_spi_link`）。

## 对应真实开源项目
- SPI 收发参考 [nandland](https://github.com/nandland/nandland)、[alexforencich](https://github.com/alexforencich) 的 SPI 实现；过采样思路见本仓 `docs/08`。
