# 10 · 时钟使能发生器 clock_enable

产生「每 DIV 拍一个使能脉冲」而非真正分频时钟——这是 FPGA 里推荐的做法（单一时钟域 + 使能，避免多时钟带来的 CDC/约束麻烦）。

```bash
make        # 校验 tick 间隔恒为 DIV
```
