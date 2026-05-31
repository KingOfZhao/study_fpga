# 16 · SPI 从机 spi_slave

模式0 SPI 从机，用系统时钟**过采样** sclk/cs_n/mosi（FPGA 推荐做法，避免把外部 sclk 当时钟）。上升沿采样 MOSI、下降沿更新 MISO，全双工收发。

```bash
make        # tb 内置 SPI 主机模型，三次全双工传输校验收发一致
```
