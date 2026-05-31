# 08 · 4:1 多路选择器 mux4_1

参数化位宽的 4 选 1。`case(sel)` 是组合逻辑选择的标准写法（注意补 default 防止锁存器）。

```bash
make        # 穷举 4 个 sel，自校验 [PASS]
```
