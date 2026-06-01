# 14 · 步进电机驱动 stepper_drive

4 相全步序列，`step` 推进一步、`dir` 换向。

## 这一课学什么
- 步进电机靠“按固定相序通电”一步步转动（开环即可精确定位）
- 4 相全步：相位序列循环移动，dir 决定移动方向
- step 脉冲频率 = 转速

> 软件类比：像按一个固定顺序循环点亮/熄灭 4 个输出（状态轮转），方向决定正序还是逆序。每来一个 step 就走一格。

## 运行
```bash
make        # 校验 step 推进的相序 + dir 换向
make wave
make clean
```

## 上板玩法
- 通过 ULN2003/A4988 等驱动接 28BYJ-48/NEMA 步进电机；做定位/进给。

## 动手改
1. 改半步序列（8 拍），提高分辨率与平滑度。
2. 加目标步数定位（直接看 `projects/10_stepper_position`）。

## 对应真实开源项目
- 步进相序见各 CNC/3D 打印固件（如 [Marlin](https://github.com/MarlinFirmware/Marlin) 的 stepper 思路）；定位实战见本仓 `projects/10_stepper_position`。
