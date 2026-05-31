# 约束文件（Constraints）

综合后的 RTL 要"落到"具体芯片的物理引脚和时钟上，这就是约束文件的作用。

| 文件 | 平台 | 工具 |
|------|------|------|
| [`basys3.xdc`](basys3.xdc) | Digilent Basys 3 (Xilinx Artix-7) | Vivado |
| [`icebreaker.pcf`](icebreaker.pcf) | iCEBreaker (Lattice iCE40) | nextpnr + icestorm（全开源） |

## 两类约束
1. **引脚约束（Pin）**：把顶层端口（`clk`/`led`/`btn`/`uart_tx`…）绑定到芯片物理引脚，并设置电平标准。
2. **时序约束（Timing）**：声明时钟频率（如 100MHz → period 10ns），让工具检查时序收敛。

## 这些只是模板
- 文件里大部分引脚被注释掉了，**只取消注释你顶层实际用到的端口**。
- `get_ports`/`set_io` 后面的名字必须与你顶层模块端口名**完全一致**。
- 引脚号以你手上开发板的官方原理图/Master 约束为准（不同板子、不同批次可能不同）。

## 典型上板流程
- Xilinx：Vivado 里 `加约束 → 综合 → 实现 → 生成 bitstream → 下载`。
- iCE40（开源）：见 [`../docs/01_environment.md`](../docs/01_environment.md) 的 yosys + nextpnr + icepack + iceprog 流程。

> 本仓库案例以**仿真验证**为主；上板时给案例写一个顶层 wrapper（把 `clk/rst/led` 等接到约束里的引脚）即可。
