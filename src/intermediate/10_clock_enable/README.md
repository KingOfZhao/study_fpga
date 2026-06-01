# 10 · 时钟使能发生器 clock_enable

产生「每 DIV 拍一个使能脉冲」，而不是真正分频出一个新时钟。

## 这一课学什么
- **单一时钟域 + 使能** 是 FPGA 推荐做法（不要随便派生时钟）
- 派生时钟会带来 CDC、时钟树、约束等一堆麻烦；用 enable 脉冲门控就能“慢速运行”而仍在同一时钟域
- 计数到 DIV-1 时拉高一拍 `tick`

> 软件类比：与其开很多不同频率的定时器，不如用一个高频主循环 + 计数判断“这一拍该不该执行”。`tick` 就是“这一拍执行”的标志。

## 运行
```bash
make        # 校验 tick 间隔恒为 DIV
make wave
make clean
```

## 上板玩法
- 几乎所有“慢速”逻辑（秒表 tick、扫描刷新、采样节拍）都用它，而不是分频时钟。

## 动手改
1. 参数化 DIV，运行时可调（接近 `intermediate/19_prog_timer`）。
2. 用它驱动 `intermediate/07_stopwatch` 的 1Hz 节拍。

## 对应真实开源项目
- “用 clock enable 而非派生时钟”是 Xilinx/Intel 官方推荐；详见本仓 `docs/08_hardware_and_synthesis.md` 的时钟章节。
