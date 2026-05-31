# FPGA 系统学习路线（面向有软件经验的工程师）

> 你已经有 7 年软件经验，所以这条路线**跳过编程基础**，聚焦"硬件思维"和 FPGA 特有的东西。
> 每个阶段都有：要建立的概念 → 本仓库对应案例 → 自检里程碑。

## 心态准备：最重要的一次"范式切换"

写软件：代码是**指令序列**，CPU 一条条执行。
写 RTL：代码是**电路描述**，所有 `always`/`assign` 块**同时、永远**在工作。

```
软件：   step1 -> step2 -> step3   （时间上串行）
硬件：   block1 ‖ block2 ‖ block3  （空间上并行，每个时钟同时推进）
```

先读 [`02_for_software_engineers.md`](02_for_software_engineers.md)，把这个切换吃透，后面会顺很多。

---

## 阶段 0 · 搭好环境（半天）
- 安装开源工具链：Icarus Verilog + GTKWave + Verilator（见 [`01_environment.md`](01_environment.md)）
- 在仓库根目录跑 `make test`，确认 9 个案例全部 `[PASS]`
- **里程碑**：能独立编译并仿真 `src/basics/01_hello_verilog`，并用 GTKWave 看到波形

## 阶段 1 · 数字逻辑 + Verilog 基础（1~2 周）
- 概念：位/向量、组合 vs 时序、`wire`/`reg`、阻塞 `=` vs 非阻塞 `<=`、时钟与复位
- 案例：
  - `src/basics/01_hello_verilog` 计数器（时序逻辑、复位）
  - `src/basics/02_combinational` 全加器（组合逻辑、`assign`）
  - `src/basics/03_mux_decoder` MUX/译码器（`always @(*)`、参数化、锁存器陷阱）
  - `src/basics/04_sequential` 触发器/移位寄存器（存储的本质）
- 配套练习：[HDLBits](https://hdlbits.01xz.net/) 的 Getting Started + Verilog Language 部分
- **里程碑**：能默写"三种 always 写法"（组合/同步时序/带异步复位），并解释 `=` 与 `<=` 为什么不能混用

## 阶段 2 · 时序设计与状态机（2~3 周）
- 概念：FSM（Moore/Mealy）、三段式写法、计数器分频、时序约束直觉（建立/保持时间）
- 案例：
  - `src/intermediate/01_fsm` 交通灯（三段式 FSM）
  - `src/intermediate/02_uart` UART 收发（真实串行协议 + 波特率计数 + 跨时钟同步）
  - `src/intermediate/03_fifo` 同步 FIFO（片上 RAM + 指针 + 满空判定）
- **里程碑**：独立写一个 FSM 解析某种简单协议；理解 FIFO 为什么是模块间解耦的利器

## 阶段 3 · 外设与接口、上板（3~4 周）
- 概念：时钟管理（PLL/MMCM）、去抖、跨时钟域（CDC）、约束文件、综合/布局布线/烧录
- 案例：
  - `src/advanced/01_pwm_led` PWM（LED 呼吸灯/电机）
  - `src/advanced/02_spi_master` SPI 主机（同步串行总线）
  - 约束示例见 [`../constraints/`](../constraints/)
- 实操：把任意一个案例综合并**烧到真实开发板**（见 [`01_environment.md`](01_environment.md) 厂商工具部分）
- **里程碑**：板子上按键去抖后驱动 LED/数码管；用 SPI 读一个真实传感器

## 阶段 4 · 进阶专题（持续）
- DSP（FIR 滤波器、定点运算、流水线）
- 高速接口（DDR、以太网、PCIe、SerDes）—— 多用厂商 IP
- SoC：在 FPGA 里跑软核（RISC-V / Microblaze / Nios）
- 验证：SystemVerilog/UVM、形式化验证、覆盖率
- **里程碑**：完成一个综合项目，例如 VGA 显示、数字示波器、简易 CPU

---

## 推荐节奏
- 每个案例：先读 README → 跑 `make` 看 `[PASS]` → `make wave` 看波形 → 按"动手改"修改并重新验证
- 每周至少做 10 道 HDLBits
- 坚持"先仿真通过，再上板"——这是硬件开发省时间的铁律

## 配套资料
精选开源项目与权威站点见 [`05_resources.md`](05_resources.md)。
