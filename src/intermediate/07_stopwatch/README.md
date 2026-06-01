# 07 · 秒表 stopwatch

级联 BCD 计数实现 mm:ss 计时，支持 run / stop / clr 控制。

## 这一课学什么
- 多个 BCD 计数器级联做分钟:秒（逢 60 进位）
- 控制信号（运行/暂停/清零）如何门控计数
- 把 1Hz 节拍 `tick` 抽象成输入——便于仿真，上板时由分频器提供

> 软件类比：像一个用定时器回调驱动的计时器对象，`run/stop/clr` 是它的方法。这里把“1 秒到了”抽象成一个输入脉冲，逻辑只管在脉冲上累加。

## 运行
```bash
make        # 走 125 个 tick，校验显示 02:05
make wave
make clean
```

## 上板玩法
- `tick` 接 1Hz 分频器（见 `basics/06_clock_divider`），三个按键接 run/stop/clr，数码管显示 mm:ss。

## 动手改
1. 加百分秒位（mm:ss.cc），`tick` 改 100Hz。
2. 接 `projects/07_stopwatch_seg` 直接上数码管显示。

## 对应真实开源项目
- 秒表/数字钟是经典入门项目；可参考 [fpga4fun](https://www.fpga4fun.com/) 的计时器示例与本仓 `projects/07_stopwatch_seg`。
