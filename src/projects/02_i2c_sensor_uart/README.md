# 组合项目 02 · I2C 读传感器 + UART 上报

工业/物联网里最典型的"采集 → 上报"链路：FPGA 用 **I2C** 读温湿度/气压/IMU 等传感器寄存器，
再用 **UART** 把数据发给上位机（PC、MCU、模组）。本例把两个协议外设组合成一条完整数据通路。

```
   go ─▶┌──────────────┐  data  ┌──────────┐ tx_byte/tx_dv ┌─────────┐ tx_serial
        │  i2c_master  │───────▶│   FSM    │──────────────▶│ uart_tx │──────────▶ PC
        └─────┬────────┘        └──────────┘               └─────────┘
        SCL/SDA（开漏总线）
              │
        ┌─────▼────────┐
        │ 传感器(I2C从机)│   ← testbench 里的行为模型，按地址应答并返回固定字节
        └──────────────┘
```

## 这一课学什么（协议外设组合）
- **I2C 时序**：START / 7 位地址+R/W / ACK / 数据位（SCL 低变化、SCL 高有效）/ NACK / STOP
- **开漏总线**：SDA 只能"拉低或释放"，靠上拉电阻回到高——testbench 用 `pullup` + 多驱动 `1'bz` 建模
- **输出寄存器化**：SCL/SDA 用寄存器输出，避免组合毛刺在总线上造成假沿（本例特意如此）
- **跨外设握手 FSM**：等 I2C `done` → 锁存数据 → 触发 UART → 等 `tx_done`
- **复用 UART**：直接实例化 `intermediate/02_uart` 的 `uart_tx`

> 软件类比：`val v = i2c.readReg(addr); uart.write(v)`——但这里 I2C/UART 各自是并行硬件状态机，
> 顶层 FSM 负责把两者的"完成事件"串起来。

## 模块清单
| 文件 | 作用 |
|------|------|
| `i2c_master.v` | 最简 I2C 单字节读主机（含开漏 SDA、寄存器化 SCL/SDA） |
| `uart_tx.v`（复用 `intermediate/02_uart`） | 8N1 串口发送 |
| `i2c_sensor_uart.v` | 顶层：I2C 读 → UART 上报 的握手 FSM |

## 运行
```bash
make            # tb 内置 I2C 从机(传感器)模型 + 行为级 UART 接收器
                # 校验：地址被应答、UART 收到字节 == 传感器返回值(0xA5) → [PASS]
make wave       # 看 SCL/SDA 上的 START/地址/ACK/数据/STOP，以及 UART 串行波形
make lint
make clean
```

## 上板玩法
- `scl`/`sda_oe`/`sda_i` 接真实 I2C 传感器（如 BMP280/SHT3x），注意 SDA 要接成开漏（用 `inout` + 三态）。
- `tx_serial` 接 USB-UART 桥（如 CP2102），PC 上用串口助手看上报字节。

## 动手改
1. 把"单字节读"扩展为"先写寄存器地址、再 repeated-start 读"（标准传感器读法）。
2. 周期性触发 `go`（配 `basics/06_clock_divider`），做成定时采集上报。
3. 上报改成多字节带帧头/校验和的协议包。
