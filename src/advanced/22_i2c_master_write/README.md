# 22 · I2C 主机(多字节写) i2c_master_write

START→地址+写位→ACK→连续写 N 字节(各等 ACK)→STOP。tb 内置简易从机捕获并应答。

```bash
make
```
