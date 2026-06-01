# 07 · 半加器 half_adder

最基础的组合逻辑单元：把两个 1 位数相加，得到本位和 `sum` 与进位 `cout`。

## 这一课学什么
- **真值表 → 布尔表达式**：`sum = a ^ b`（异或=不进位的加），`cout = a & b`（同为 1 才进位）
- 纯组合逻辑：输出只由当前输入决定，没有时钟、没有状态
- 它是全加器、多位行波进位加法器、ALU 的最小基石

> 软件类比：相当于一个无副作用的纯函数 `(int a, int b) => (a ^ b, a & b)`。但硬件里它是“常在”的——只要输入变了，输出立刻跟着变，不需要被“调用”。

## 运行
```bash
make        # 穷举 4 种输入，自校验 [PASS]
make wave   # 看波形
make clean
```

## 上板玩法
- 用两个拨码开关接 `a`/`b`，两个 LED 接 `sum`/`cout`，拨一拨就能看真值表。

## 动手改
1. 把两个半加器 + 一个或门拼成**全加器**（带进位输入 `cin`）。
2. 用 4 个全加器级联成 **4 位加法器**，对照 `basics/05_alu` 的加法部分。

## 对应真实开源项目
- [Obijuan/open-fpga-verilog-tutorial](https://github.com/Obijuan/open-fpga-verilog-tutorial) 从门级到加法器的渐进教程。
- 教科书《Digital Design and Computer Architecture》(Harris) 加法器章节。
