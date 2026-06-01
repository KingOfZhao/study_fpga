# 10 · 乘累加器 mac

每个 valid 拍 `acc += a*b`，是 DSP 滤波/卷积/矩阵乘的核心。

## 这一课学什么
- 乘累加（MAC）= 乘法器 + 加法器 + 累加寄存器
- FPGA 的 **DSP48/DSP block** 就是为这个操作硬件加速的专用单元
- valid 控制何时累加、clr 清零开始新一轮

> 软件类比：就是 `acc += a * b` 放进循环——点积/卷积的内层。FPGA 把它做成专用硬件块，可以几百个并行，这是它碾压 CPU 做 DSP/AI 的根本原因。

## 运行
```bash
make        # 累加一串 a*b，对照参考和校验
make wave
make clean
```

## 上板玩法
- FIR/IIR 滤波、矩阵乘、神经网络 MAC 阵列的基本单元。

## 动手改
1. 做成多抽头 FIR（多个 MAC 并行 + 加法树）。
2. 加饱和/舍入处理定点溢出。

## 对应真实开源项目
- MAC 是 DSP/AI 加速核心；参考 Xilinx DSP48E 文档、各开源 FIR/CNN 加速器（如 [CFU-Playground](https://github.com/google/CFU-Playground)）。
