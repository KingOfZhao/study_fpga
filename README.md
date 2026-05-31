# Study FPGA · 系统化 FPGA 学习项目

一套**面向有软件经验工程师**的 FPGA 系统学习项目：从"软件思维 → 硬件思维"的迁移讲起，
配 16 个**可运行、带自校验测试**的 Verilog 案例（基础 → 进阶 → 高级，台阶平滑、可线性学习），统一的运行/调试方法，
全程可用**开源工具链**在本机仿真，无需开发板即可上手。

> 如果你和作者一样有多年软件经验，强烈建议先读 [`docs/02_for_software_engineers.md`](docs/02_for_software_engineers.md)，
> 它会帮你跨过"并行 vs 串行"这个最大的认知坎。

## 30 秒上手

```bash
# 1) 安装开源工具链（Ubuntu/Debian）
sudo apt-get install -y iverilog gtkwave verilator make
#    macOS: brew install icarus-verilog gtkwave verilator make

# 2) 克隆并一键跑通全部案例（应全部 [PASS]）
git clone https://github.com/KingOfZhao/study_fpga.git
cd study_fpga
make test

# 3) 跑单个案例并看波形
cd src/basics/01_hello_verilog
make          # 自校验仿真
make wave     # GTKWave 看波形
```

详细安装（含 Windows/WSL、厂商工具、开发板选型）见 [`docs/01_environment.md`](docs/01_environment.md)。

## 🌐 可视化 Web 平台（在线改代码 + 实时波形 + 交互式芯片仿真）

不想敲命令行？仓库自带一个 Web 平台：浏览器里直接改 Verilog，后端用真实 `iverilog`/`vvp` 仿真，
用 **Canvas 画波形**；组合逻辑还能**拨动输入开关、实时看输出 LED**。

```bash
cd web
./run.sh            # macOS/Linux 一键启动（需先 brew install icarus-verilog）
# 浏览器打开 http://localhost:8000
```

完整说明（macOS 部署、运行、调试、芯片仿真操作方法、架构）见 [`web/README.md`](web/README.md)。

## 学习路线（建议按顺序）

先读文档建立框架，再逐个跑案例。完整路线与里程碑见 [`docs/00_roadmap.md`](docs/00_roadmap.md)。

| 阶段 | 案例 | 学到的核心概念 |
|------|------|----------------|
| **基础** | [`basics/01_hello_verilog`](src/basics/01_hello_verilog) | 计数器、时序逻辑、复位、第一个波形 |
| | [`basics/02_combinational`](src/basics/02_combinational) | 组合逻辑、全加器、`assign` |
| | [`basics/03_mux_decoder`](src/basics/03_mux_decoder) | MUX/译码器、`always @(*)`、锁存器陷阱 |
| | [`basics/04_sequential`](src/basics/04_sequential) | 触发器、移位寄存器、`<=` vs `=` |
| | [`basics/05_alu`](src/basics/05_alu) | ALU、`case` 多路运算、进位/溢出、参数化位宽 |
| | [`basics/06_clock_divider`](src/basics/06_clock_divider) | 分频/节拍发生器、使能脉冲、`$clog2` |
| **进阶** | [`intermediate/01_fsm`](src/intermediate/01_fsm) | 三段式状态机（交通灯） |
| | [`intermediate/02_uart`](src/intermediate/02_uart) | UART 收发、波特率计数、跨时钟同步 |
| | [`intermediate/03_fifo`](src/intermediate/03_fifo) | 同步 FIFO、片上 RAM、指针/满空 |
| | [`intermediate/04_debounce`](src/intermediate/04_debounce) | 按键消抖、两级同步、边沿检测脉冲 |
| | [`intermediate/05_seven_seg`](src/intermediate/05_seven_seg) | 二进制转 BCD、7 段译码、扫描复用显示 |
| | [`intermediate/06_ram`](src/intermediate/06_ram) | 片上 Block RAM、同步读写、读延迟 |
| **高级** | [`advanced/01_pwm_led`](src/advanced/01_pwm_led) | PWM、LED 呼吸灯/电机调速 |
| | [`advanced/02_spi_master`](src/advanced/02_spi_master) | SPI 主机、全双工同步串行总线 |
| | [`advanced/03_vga`](src/advanced/03_vga) | VGA 时序、行/场同步、像素坐标 |
| | [`advanced/04_fir`](src/advanced/04_fir) | 移动平均/FIR、滑动窗口、定点 DSP |

每个案例目录都包含：设计 `*.v` + 自校验 testbench `*_tb.v` + `Makefile` + `README.md`（原理/运行/动手改）。

## 统一的运行 / 调试接口

| 命令 | 作用 |
|------|------|
| `make test` | （根目录）跑所有案例的自校验仿真并汇总 |
| `make lint` | （根目录）对所有设计做 verilator 静态检查 |
| `make list` | 列出全部案例目录 |
| `make`（案例内） | 编译 + 仿真，打印 `[PASS]`/`[FAIL]` |
| `make wave`（案例内） | 用 GTKWave 打开波形 |
| `make clean` | 清理生成文件 |

调试方法（波形 / 打印 / lint / testbench 纪律）详见 [`docs/03_simulation_and_debug.md`](docs/03_simulation_and_debug.md)。

## 文档导航

| 文档 | 内容 |
|------|------|
| [`docs/00_roadmap.md`](docs/00_roadmap.md) | 系统学习路线与阶段里程碑 |
| [`docs/01_environment.md`](docs/01_environment.md) | 环境部署（开源工具链 + 厂商工具 + 开发板） |
| [`docs/02_for_software_engineers.md`](docs/02_for_software_engineers.md) | 软件 → 硬件思维迁移（重点先读） |
| [`docs/03_simulation_and_debug.md`](docs/03_simulation_and_debug.md) | 运行方法与调试方法 |
| [`docs/04_tools_and_components.md`](docs/04_tools_and_components.md) | FPGA 内部资源 + 工具链 + 组件总览 |
| [`docs/05_resources.md`](docs/05_resources.md) | 精选开源项目与权威学习资料 |
| [`docs/verilog_cheatsheet.md`](docs/verilog_cheatsheet.md) | Verilog 语法速查 |
| [`constraints/`](constraints) | 上板引脚约束模板（Basys3 / iCE40） |

## 目录结构

```
study_fpga/
├── README.md                # 本文件：学习门户
├── Makefile                 # 顶层：make test / lint / list / clean
├── common.mk                # 所有案例共用的仿真规则
├── docs/                    # 系统文档（路线/环境/思维/调试/工具/资料）
├── src/
│   ├── basics/              # 基础案例 01-06
│   ├── intermediate/        # 进阶案例 01-06
│   └── advanced/            # 高级案例 01-04
├── constraints/             # 上板引脚约束模板
├── scripts/                 # run_all.sh / lint_all.sh
├── web/                     # 🌐 可视化 Web 平台（FastAPI 后端 + Canvas 波形前端）
└── .github/workflows/ci.yml # CI：自动跑全部自校验仿真
```

## 工具链

仿真/学习全程开源：**Icarus Verilog**（仿真）+ **GTKWave**（波形）+ **Verilator**（静态检查）+ **make**。
上板时再按需安装 Vivado / Quartus / 开源 icestorm 流程。

## 贡献
见 [CONTRIBUTING.md](CONTRIBUTING.md)。
