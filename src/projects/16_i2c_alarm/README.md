# 16 · I2C 传感器超阈报警 i2c_alarm

`i2c_master 读传感器 + 阈值比较`：周期读值，超阈则报警(LED/标志)。

## 这一课学什么
- 周期性采集 → 判断 → 执行 的监控闭环
- I2C 主机读传感器寄存器（多字节读时序）
- 阈值比较触发动作（迟滞可避免抖动报警）

> 软件类比：像一个轮询监控任务——定时读传感器、和阈值比较、超了就触发告警。整套“采集-判断-动作”流程在硬件里并行常驻。

## 运行
```bash
make        # tb 内置传感器模型给不同读数，校验报警触发/解除
make wave
make clean
```

## 上板玩法
- 温度/光照超阈报警；上板 I2C 需上拉 + inout 三态（见 `hardening/i2c_iobuf_top.v`）。

## 动手改
1. 加迟滞（上限触发、下限解除）防抖动。
2. 报警同时串口上报读数（接 `intermediate/02_uart`）。

## 对应真实开源项目
- I2C 读传感器实现参考 [alexforencich/verilog-i2c](https://github.com/alexforencich/verilog-i2c)；I2C 主机内核见本仓 `advanced/22_i2c_master_write`。
