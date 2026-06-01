# 30 · 多路按键消抖 debounce_multi

对 N 路按键各自独立消抖：每路同步器 + 稳定计数器，稳定 STABLE 拍后才更新输出。

## 这一课学什么
- 机械按键会抖动（毫秒级多次跳变）→ 必须消抖才能可靠计数
- 每路：先过同步器（异步信号），再用计数器要求“连续稳定 N 拍”才认值
- 用 `generate` 把单路消抖复制成 N 路（参数化）

> 软件类比：像对多个输入源各自做 debounce——只有信号稳定一段时间才认为“真的变了”。`generate` 相当于用循环批量实例化同一个组件。

## 运行
```bash
make        # 注入带抖动的多路输入，校验输出干净稳定
make wave
make clean
```

## 上板玩法
- 同时处理多个机械按键/拨码开关；每路输出再接边沿检测得“按下事件”。

## 动手改
1. 输出加同步的按下/松开事件脉冲。
2. 调 STABLE 阈值，观察抗抖与响应延迟的权衡。

## 对应真实开源项目
- 按键消抖是上板第一课；参考 [fpga4fun debounce](https://www.fpga4fun.com/Debouncer.html) 与本仓 `intermediate/04_debounce`、`hardening/synchronizer.v`。
