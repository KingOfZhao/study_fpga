# 23 · VGA 彩条发生器 vga_pattern

按像素 x 坐标分 8 条标准彩条(黑/蓝/绿/青/红/品红/黄/白)。

## 这一课学什么
- 像素坐标 → 颜色 的纯组合映射（最简单的“图形渲染”）
- 彩条 = 按 x 区间选 RGB（电视测试图思路）
- 配 `advanced/03_vga` 的行/场同步时序即可上屏

> 软件类比：像一个 `(x,y) => color` 的着色器函数——给定屏幕坐标返回颜色。这里是最朴素的版本（只看 x 分段）。

## 运行
```bash
make        # 校验各 x 区间输出对应彩条颜色
make wave
make clean
```

## 上板玩法
- 接 VGA DAC（电阻网络即可）输出彩条到显示器，验证显示链路。

## 动手改
1. 改成棋盘格/渐变/同心圆等图案。
2. 加可移动方块（直接看 `projects/13_vga_box`）。

## 对应真实开源项目
- VGA 彩条是显示入门经典；参考 [fpga4fun VGA](https://www.fpga4fun.com/PongGame.html) 与 [Project F 的显示教程](https://projectf.io/posts/fpga-graphics/)。
