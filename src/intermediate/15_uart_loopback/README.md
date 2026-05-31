# 15 · UART 自环 uart_loopback

把已有的 `uart_tx` + `uart_rx` 组合成收发链路，TX 直接接回 RX。演示模块复用与串口收发闭环。

```bash
make        # 连发 4 字节，校验自环收回一致
```
