# 环境部署

本项目所有案例都能用**开源工具链**在本机仿真，无需任何商业软件、无需开发板即可学习。
上板（综合/烧录）时再装厂商工具。

## 一、开源工具链（必装，用于仿真与学习）

| 工具 | 作用 | 类比 |
|------|------|------|
| **Icarus Verilog (`iverilog`/`vvp`)** | 编译并仿真 Verilog | 编译器 + 运行时 |
| **GTKWave** | 查看仿真波形（.vcd/.fst） | 调试器的"变量视图" |
| **Verilator** | 超快仿真 + 静态检查（lint） | 静态分析 + 高性能模拟器 |
| **Yosys**（可选） | 开源综合（RTL → 门级网表） | 把"代码"变成"电路" |
| **make** | 一键编译/仿真 | 任务运行器 |

### Linux（Ubuntu/Debian）
```bash
sudo apt-get update
sudo apt-get install -y iverilog gtkwave verilator yosys make
```

### macOS（Homebrew）
```bash
brew install icarus-verilog gtkwave verilator yosys make
```

### Windows
推荐用 **WSL2 + Ubuntu**，然后按上面的 Linux 步骤安装（GTKWave 在 WSLg 下可直接显示窗口）。
或使用 [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build/releases)（一个压缩包含 iverilog/verilator/yosys/gtkwave 等，解压即用，跨平台）。

### 验证安装
```bash
iverilog -V        # Icarus Verilog version 11.x
verilator --version
gtkwave --version
make --version
```
本项目在 `iverilog 11.0`、`verilator 4.038` 上验证通过。

### 一键跑通全部案例
```bash
git clone https://github.com/KingOfZhao/study_fpga.git
cd study_fpga
make test          # 9 个案例应全部 [PASS]
```

## 二、厂商工具（上板时再装）

> 仅在你要把设计综合并烧到**真实 FPGA 开发板**时才需要。仿真学习阶段不需要。

| 厂商 | 工具 | 适用器件 | 备注 |
|------|------|----------|------|
| **AMD/Xilinx** | [Vivado](https://www.xilinx.com/support/download.html) | Artix-7/Zynq 等 | 体积大（几十 GB）；Basys3/Nexys 用它 |
| **Intel/Altera** | [Quartus Prime Lite](https://www.intel.com/content/www/us/en/software-kits/) | Cyclone 等 | Lite 版免费 |
| **Lattice** | [Radiant](https://www.latticesemi.com/) 或开源 **icestorm** | iCE40/ECP5 | iCE40 可全开源流程烧录 |

### 全开源上板流程（以 Lattice iCE40 为例）
```bash
# 综合 -> 布局布线 -> 生成比特流 -> 烧录
yosys -p "synth_ice40 -top top -json top.json" top.v
nextpnr-ice40 --hx1k --json top.json --pcf constraints/ice40.pcf --asc top.asc
icepack top.asc top.bin
iceprog top.bin
```
（需要额外安装 `nextpnr` + `icestorm` 工具集，OSS CAD Suite 里都有。）

## 三、推荐开发板（按预算）
| 板子 | 芯片 | 流程 | 适合 |
|------|------|------|------|
| iCEBreaker / TinyFPGA | Lattice iCE40 | 全开源 | 入门、最省心 |
| Digilent Basys 3 | Xilinx Artix-7 | Vivado | 教学经典，外设丰富 |
| Digilent Nexys A7 | Xilinx Artix-7 | Vivado | 进阶，资源多 |
| Terasic DE10-Lite | Intel MAX10 | Quartus | Intel 阵营入门 |

## 四、编辑器
- VS Code + 插件：`Verilog-HDL/SystemVerilog`（语法高亮、跳转）、`WaveTrace`（行内看波形）
- 配合 `verilator --lint-only` 做保存即检查

下一步：读 [`03_simulation_and_debug.md`](03_simulation_and_debug.md) 学习如何运行与调试。
