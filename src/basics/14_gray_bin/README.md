# 14 · 格雷码互转 gray_bin

`bin→gray = b ^ (b>>1)`；`gray→bin` 用前缀异或。格雷码相邻值只差 1 位，常用于异步 FIFO 跨时钟指针。testbench 校验往返一致 + 相邻仅 1 位变化。

```bash
make
```
