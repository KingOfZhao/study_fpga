# 组件与工具总览（FPGA 里到底有哪些"零件"）

两条主线：① FPGA 芯片**内部**有哪些硬件资源；② 开发流程里用到哪些**工具**。

## 一、FPGA 芯片内部的硬件资源

FPGA = Field Programmable Gate Array，"现场可编程门阵列"。它内部是一片可配置的硬件资源：

| 资源 | 作用 | 你写的什么会用到它 |
|------|------|---------------------|
| **LUT（查找表）** | 实现任意组合逻辑（真值表） | `assign`、`always @(*)` |
| **触发器 FF / 寄存器** | 存 1 bit，时钟沿更新 | `reg` + `always @(posedge clk)` |
| **CLB / Slice / LE** | LUT+FF 打包成的基本单元 | 综合后自动映射 |
| **Block RAM (BRAM)** | 片上存储块（KB 级） | `reg [..] mem [..]`（如 FIFO） |
| **DSP Slice** | 硬件乘法器/累加器 | `*`、乘加（滤波器） |
| **PLL / MMCM / DCM** | 时钟综合：倍频/分频/移相 | 生成不同频率时钟 |
| **I/O Block (IOB)** | 引脚缓冲、电平标准、上下拉 | 约束文件里配置 |
| **全局时钟网络** | 低偏斜地把时钟送到全片 | 时钟信号自动走专用网络 |
| **硬核 IP** | 以太网 MAC、PCIe、DDR 控制器、SerDes、甚至 CPU（Zynq 的 ARM） | 调用厂商 IP |

> 关键直觉：你写的 RTL 最终是"占用这些资源 + 把它们连起来"。资源是**有限的**，所以面积/时序是真实约束。

## 二、设计层面的"组件"（你会反复用到的电路积木）

| 积木 | 用途 | 本仓库案例 |
|------|------|------------|
| 计数器 / 分频器 | 计时、产生慢时钟 | `basics/01`、PWM、UART 波特率 |
| 组合逻辑（加法器/MUX/译码器） | 运算与选择 | `basics/02`、`basics/03` |
| 触发器 / 移位寄存器 | 存储、串并转换 | `basics/04` |
| 有限状态机 FSM | 控制流 | `intermediate/01` |
| FIFO / RAM | 缓冲、跨模块解耦 | `intermediate/03` |
| 串行接口（UART/SPI/I2C） | 与外设通信 | `intermediate/02`、`advanced/02` |
| PWM | 模拟量控制 | `advanced/01` |
| 跨时钟域同步器 | 安全跨时钟传数据 | UART 的 `rx_d1/rx_d2` |

## 三、HDL 与设计语言
- **Verilog / SystemVerilog**：本仓库使用，业界最主流之一。
- **VHDL**：另一主流，语法更严格啰嗦，欧洲/航天军工常见。
- **HLS（高层次综合）**：用 C/C++ 描述算法综合成 RTL（Vitis HLS），适合算法工程师。
- **Chisel / SpinalHDL / Amaranth**：用 Scala/Python 生成 RTL 的新派工具，软件工程师可能更亲切。

## 四、工具链与开发流程

```
        ┌─────────────┐   仿真验证   ┌──────────────┐
RTL ───▶│  仿真器       │◀──testbench │  GTKWave     │
(.v)    │ iverilog/    │             │  看波形       │
        │ verilator    │             └──────────────┘
        └──────┬──────┘
               │ 验证通过
               ▼
        ┌─────────────┐    ┌────────────┐    ┌──────────┐    ┌──────────┐
        │  综合 Synth   │──▶│ 布局布线 P&R │──▶│ 生成比特流 │──▶│ 烧录 Prog │──▶ FPGA
        │ yosys/vivado │    │ nextpnr/   │    │ bitstream │    │ 下载到板  │
        └─────────────┘    │ vivado     │    └──────────┘    └──────────┘
                           └────────────┘
```

| 阶段 | 做什么 | 开源工具 | 厂商工具 |
|------|--------|----------|----------|
| **仿真** | 验证功能正确 | iverilog + vvp、verilator | Vivado XSim、ModelSim/Questa |
| **静态检查** | 提前抓 bug | verilator --lint-only | 各家自带 |
| **综合** | RTL → 门级网表 | yosys | Vivado、Quartus |
| **布局布线** | 网表 → 具体器件资源+布线 | nextpnr | Vivado、Quartus |
| **约束** | 指定引脚/时钟频率 | `.pcf`(iCE40) | `.xdc`(Xilinx)/`.sdc`(Intel) |
| **生成比特流** | 产生可烧录文件 | icepack | Vivado/Quartus |
| **烧录** | 下载到 FPGA | iceprog/openFPGALoader | 厂商下载器 |
| **片上调试** | 抓真实运行信号 | — | ILA / SignalTap |

## 五、约束文件（Constraints）
综合后的设计要"落到"具体引脚和时钟，这由约束文件描述：
- **引脚约束**：把 `clk`、`led`、`btn` 等端口绑定到芯片物理引脚。
- **时序约束**：声明时钟频率，让工具检查时序是否收敛（建立/保持时间）。

本仓库 [`../constraints/`](../constraints/) 提供 Basys3（`.xdc`）和 iCE40（`.pcf`）的引脚约束模板。

## 六、IP 核（IP Core）
厂商/社区提供的现成模块（FIFO、RAM、UART、以太网、DDR 控制器、PCIe、软核 CPU 等），
用图形化或例化方式直接调用，避免重复造轮子。学习阶段建议自己实现基础组件理解原理，
工程阶段对复杂高速接口直接用 IP。
