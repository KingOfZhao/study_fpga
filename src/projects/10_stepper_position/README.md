# 10 · 步进电机定位 stepper_position

给定目标步数，控制器自动发 step/dir 使当前位置收敛到目标。

## 这一课学什么
- 闭环（这里是开环计步）定位：比较当前位置与目标，决定方向并发步
- 到位即停（误差为 0 停止发 step）
- 把“连续驱动”升级为“点到点定位”

> 软件类比：像 `moveTo(target)`——比较当前与目标，朝差值方向逐步逼近直到相等。每一步就是一个 step 脉冲。

## 运行
```bash
make        # 设定目标步数，校验位置收敛且方向正确
make wave
make clean
```

## 上板玩法
- 3D 打印/CNC 进给、相机滑轨等点到点定位场景。

## 动手改
1. 加加减速曲线（梯形速度规划），避免丢步。
2. 接编码器做真正的闭环（对照 `projects/01_encoder_pwm_loop` 的闭环思路）。

## 对应真实开源项目
- 步进定位/速度规划见 [Marlin](https://github.com/MarlinFirmware/Marlin)、[GRBL](https://github.com/gnea/grbl) 的运动控制；驱动内核见本仓 `advanced/14_stepper_drive`。
