# 06 · 频率计+数码管 freq_meter_seg

`freq_counter + bin2bcd + seg7x3`：测量输入信号频率并在三位数码管显示。

## 这一课学什么
- 测量 → 进制转换 → 显示 的完整仪表链路
- 二进制计数值要转 BCD（double dabble）才能上数码管
- 显示用动态扫描

> 软件类比：像“采集数值 → 格式化成十进制字符串 → 渲染到 UI”。bin2bcd 就是格式化、数码管扫描就是渲染。

## 运行
```bash
make        # 给定频率输入，校验数码管显示的十进制值
make wave
make clean
```

## 上板玩法
- 一个真正的数字频率计：测外部信号频率并实时显示。

## 动手改
1. 扩到更多位/带单位指示。
2. 量程切换（自动选闸门时间）。

## 对应真实开源项目
- 频率计 + 显示综合了多个经典模块；参考 [fpga4fun frequency counter](https://www.fpga4fun.com/) 与本仓 `intermediate/21_freq_counter`、`intermediate/05_seven_seg`。
