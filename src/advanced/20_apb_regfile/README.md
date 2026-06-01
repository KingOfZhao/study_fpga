# 20 · APB 寄存器堆 apb_regfile

APB-lite 从设备，标准 setup + access 两相读/写时序，常作为外设配置接口。

## 这一课学什么
- APB 是 AMBA 总线家族里最简单的一种（无流水、无突发），适合配置寄存器
- 两相时序：`PSEL` 拉高进 setup，下一拍 `PENABLE` 拉高进 access 完成传输
- 总线地址译码到具体寄存器读写

> 软件类比：像一个内存映射的配置对象——CPU 往某地址“写字段”就配置了外设，“读字段”就拿到状态。APB 定义了这次读写的握手时序。

## 运行
```bash
make        # 按 APB 时序读写寄存器，校验读回值
make wave
make clean
```

## 上板玩法
- 给你的自定义外设加一套寄存器配置接口，挂到软核(如 RISC-V) 的 APB 总线上。

## 动手改
1. 加只读状态寄存器、写 1 清零寄存器等常见寄存器类型。
2. 改成 AXI4-Lite 接口（更主流）。

## 对应真实开源项目
- APB/AXI 规范见 ARM AMBA 文档；总线外设实战参考 [pulp-platform/apb](https://github.com/pulp-platform) 系列与各 RISC-V SoC。
