# 07 · 秒表+数码管 stopwatch_seg

`stopwatch + seg7x4`：mm:ss 计时并在 4 位数码管显示。

## 这一课学什么
- 把秒表内核接上真实显示外设
- BCD 计时值直接送 4 位动态扫描数码管
- 完整可上板的“数字秒表”

> 软件类比：把业务逻辑（计时）和视图（数码管显示）接起来——典型的“模型驱动视图”。

## 运行
```bash
make        # 走若干 tick，校验数码管显示 mm:ss
make wave
make clean
```

## 上板玩法
- 真正的数字秒表：按键 run/stop/clr，数码管显示分:秒；tick 用 1Hz 分频。

## 动手改
1. 加百分秒位。
2. 加“分段计时”（lap）记录。

## 对应真实开源项目
- 数字钟/秒表是经典综合实验；参考各开发板官方例程与本仓 `intermediate/07_stopwatch`、`intermediate/17_seven_seg_mux4`。
