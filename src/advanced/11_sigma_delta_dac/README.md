# 11 · Sigma-Delta DAC sigma_delta_dac

一阶 Σ-Δ 调制：1-bit 比特流的平均密度正比于 `level`，配 RC 低通即得模拟电压。

## 这一课学什么
- 只用 1 根普通 IO + 一个 RC 就能输出模拟电压（不需要专用 DAC 芯片）
- 一阶 Σ-Δ：误差累加器溢出就输出 1，把量化误差“推”到高频
- 比 PWM 频谱更友好（噪声整形）

> 软件类比：像用“误差扩散”抖动算法把灰度值表示成黑白点的密度（类似图像 dithering）。这里是时间维度上的密度调制。

## 运行
```bash
make        # 校验输出 1 的密度与 level 成正比
make wave
make clean
```

## 上板玩法
- FPGA 单脚 + RC 输出音频/控制电压；常用于无 DAC 的低成本模拟输出。

## 动手改
1. 升到二阶调制器，对比噪声整形效果。
2. 接正弦 ROM 输出模拟正弦波。

## 对应真实开源项目
- Σ-Δ DAC 是 fpga4fun 经典；参考 [fpga4fun PWM/DAC](https://www.fpga4fun.com/PWM_DAC.html) 与各音频 FPGA 项目。
