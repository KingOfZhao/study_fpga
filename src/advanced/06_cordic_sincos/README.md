# 06 · CORDIC sin/cos cordic_sincos

旋转模式 CORDIC，仅用移位 + 加减计算 sin/cos（定点 Q1.14），无需乘法器。

## 这一课学什么
- CORDIC：把“旋转一个角度”分解成一串固定的微旋转，每步只用移位和加减
- 用查表的 arctan 角度序列逐步逼近目标角
- 没有乘法器也能算三角函数（省 DSP 资源的经典算法）

> 软件类比：像用一系列“越来越小的固定步长”逼近目标值的迭代算法。妙处在于每步的乘法都退化成移位——这正是硬件最擅长的。

## 运行
```bash
make        # 多个角度对照 $cos/$sin 校验误差在容限内
make wave
make clean
```

## 上板玩法
- 无乘法器器件上的三角函数、向量旋转、极坐标↔直角坐标转换。

## 动手改
1. 增加迭代级数，观察精度提升。
2. 用向量模式算 atan2/模长（同一硬件两种用法）。

## 对应真实开源项目
- CORDIC 是 DSP 经典；参考 Xilinx CORDIC IP 文档、[ZipCPU 的 CORDIC 系列教程](https://github.com/ZipCPU/cordic)。
