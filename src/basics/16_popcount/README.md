# 16 · 人口计数 popcount

统计一个向量里 1 的个数（population count / Hamming weight）。

## 这一课学什么
- 用加法树把每位累加（组合逻辑，一拍出结果）
- 对照仿真内建 `$countones` 自校验
- 应用：汉明距离、纠错码、稀疏度统计、CPU 的 popcnt 指令

> 软件类比：就是 `bits.where((b)=>b==1).length` 或 Dart 里手写的 popcount。硬件实现是并行加法树，不是逐位循环计数。

## 运行
```bash
make        # 对照 $countones 校验若干输入
make wave
make clean
```

## 上板玩法
- 统计传感器阵列中触发的通道数；或做简单的“多数表决”前置计数。

## 动手改
1. 参数化位宽，比较加法树深度随位宽的变化。
2. 用两个 popcount 算 `popcount(a ^ b)` 得到**汉明距离**。

## 对应真实开源项目
- popcount/汉明距离广泛用于纠错与相似度；可对照本仓 `intermediate/27_hamming74`。
