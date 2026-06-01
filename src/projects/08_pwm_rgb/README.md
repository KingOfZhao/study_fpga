# 08 · RGB PWM 调光 pwm_rgb

三路独立 PWM 驱动 R/G/B，组合出任意颜色/亮度。

## 这一课学什么
- 三路共享时基 PWM（对照 `advanced/12_pwm_multi`）
- 颜色 = (R,G,B) 三个占空比的组合
- 人眼对 PWM 平均亮度的感知（频率要够高不闪）

> 软件类比：就是把一个 `Color(r,g,b)` 输出到三个 PWM 通道——每个分量的占空比就是该通道亮度。混色逻辑和软件设色一模一样。

## 运行
```bash
make        # 校验三通道在各自 duty 下的输出
make wave
make clean
```

## 上板玩法
- 驱动共阴/共阳 RGB LED 或灯带，做呼吸/渐变/彩虹效果。

## 动手改
1. 用 HSV→RGB 转换做色相轮渐变。
2. 三路加不同相位错峰，降低电源瞬时电流。

## 对应真实开源项目
- RGB PWM 调光是 LED 控制经典；时基复用对照本仓 `advanced/12_pwm_multi`、`advanced/01_pwm_led`。
