# 17 · SPI 主从全双工 spi_link

`spi_master ↔ spi_slave`：主从对接，一次传输双方交换数据，校验全双工。

## 这一课学什么
- SPI 全双工本质：主从两个移位寄存器首尾相接成一个环，时钟一拍交换一位
- 主机发起时钟、片选；从机被动响应
- 端到端验证主→从、从→主同时成立

> 软件类比：像两端通过一个共享移位环“互换”数据——你给我一位，我同时给你一位，N 拍后两边都拿到对方的字节。

## 运行
```bash
make        # 主从各置发送数据，校验一次传输后互换成功
make wave
make clean
```

## 上板玩法
- 双 FPGA/MCU 间 SPI 通信；理解 SPI 外设收发同时发生的本质。

## 动手改
1. 连续多字节传输（保持片选）。
2. 加从机“准备好”握手（busy 信号）。

## 对应真实开源项目
- SPI 主/从实现参考 [nandland](https://github.com/nandland/nandland)、[alexforencich](https://github.com/alexforencich)；内核见本仓 `advanced/21_spi_master_modes`、`intermediate/16_spi_slave`。
