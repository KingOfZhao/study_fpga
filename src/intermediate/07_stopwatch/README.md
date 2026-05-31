# 07 · 秒表 stopwatch

级联 BCD 计数实现 mm:ss，支持 run/stop/clr。把 1Hz 节拍 `tick` 抽象成输入，便于仿真（上板时由分频器产生）。

```bash
make        # 走 125 个 tick，校验显示 02:05
```
