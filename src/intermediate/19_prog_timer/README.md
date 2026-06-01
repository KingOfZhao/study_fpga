# 19 · 可编程定时器 prog_timer

装载初值后倒计时，到 0 输出 `done` 脉冲。tick 抽象成输入便于仿真。

## 这一课学什么
- 可编程：初值由外部 `load` 装入，定时长度运行时可变
- 倒计时到 0 产生单拍 done（不是电平）
- 定时/超时/延时控制的通用件

> 软件类比：相当于 `Timer(duration, callback)`——装载“时长”，倒数到 0 触发一次回调（done 脉冲）。这里时间单位是 tick 数。

## 运行
```bash
make        # 装载初值倒计时，校验 done 出现在正确拍
make wave
make clean
```

## 上板玩法
- 通信超时、按键长按判定、周期性事件触发；tick 用 clock enable 产生真实时间基准。

## 动手改
1. 加自动重装（周期定时器）模式。
2. 升级成“未喂狗则超时”的看门狗（直接看 `intermediate/20_watchdog`）。

## 对应真实开源项目
- 可编程定时器是 MCU/SoC 标准外设；对照本仓 `intermediate/20_watchdog`、`advanced/20_apb_regfile`（可做成寄存器配置的定时器）。
