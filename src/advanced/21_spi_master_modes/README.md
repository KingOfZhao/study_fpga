# 21 · 可配置 SPI 主机 spi_master_modes

支持 4 种 SPI 模式(CPOL/CPHA)、全双工 8 位，回环测试覆盖全部模式。

## 这一课学什么
- SPI 的 4 种模式 = CPOL(空闲时钟电平) × CPHA(采样边沿) 的组合
- 不同从机要求不同模式，主机必须可配置
- 全双工：每拍移出 MOSI 同时移入 MISO

> 软件类比：像一个可配置的串行总线驱动——同一套收发逻辑，靠 2 个配置位适配不同从机的时序约定。理解这 4 种模式就吃透了 SPI 时序。

## 运行
```bash
make        # 回环覆盖 4 种模式，校验收发一致
make wave
make clean
```

## 上板玩法
- 读写 SPI Flash、ADC/DAC、传感器、显示屏等绝大多数 SPI 外设。

## 动手改
1. 支持可变字长（如 16/24 位）。
2. 接从机做主从链路（直接看 `projects/17_spi_link`）。

## 对应真实开源项目
- SPI 主机参考 [nandland](https://github.com/nandland/nandland)、[alexforencich](https://github.com/alexforencich) 的 SPI 实现与各 SoC 的 SPI 控制器。
