# 精选学习资料与开源项目

按"先练手 → 再系统 → 后进阶"整理。带 ⭐ 的是强烈推荐起步资源。

## 一、在线练习（边学边写，最快建立手感）
- ⭐ **[HDLBits](https://hdlbits.01xz.net/)** —— 浏览器里写 Verilog、即时判题。从语法到电路再到 FSM，循序渐进，是公认最好的入门练习。
- **[asic-world Verilog 教程](https://www.asic-world.com/verilog/)** —— 语法与示例齐全的参考站。

## 二、开源教程仓库（可对照本项目一起看）
- ⭐ **[Obijuan/open-fpga-verilog-tutorial](https://github.com/Obijuan/open-fpga-verilog-tutorial)** (854★) —— 全程**只用开源工具**（icestorm/yosys）从零到上板的 Verilog 教程，配 Wiki。
- **[naelolaiz/learning_fpga](https://github.com/naelolaiz/learning_fpga)** —— 渐进式案例（LED→PWM→UART→FIFO→VGA），每个都自动生成网表图和波形图，工程组织值得借鉴。
- **[smashembedded/icezum-digital-design](https://github.com/smashembedded/icezum-digital-design)** —— 面向 iCE40 的模块化 Verilog 练习集，从基础到中级。

## 三、学习路线 / 知识地图
- ⭐ **[m3y54m/FPGA-ASIC-Roadmap](https://github.com/m3y54m/FPGA-ASIC-Roadmap)** (562★) —— FPGA/ASIC 工程师成长路线，按主题汇总书/视频/文章并标注难度。
- **[Nandland](https://nandland.com/)** —— FPGA 101、Go Board 教程，文章 + 视频，讲解通俗，强烈推荐配合看。
- **[fpga4fun](https://www.fpga4fun.com/)** —— 经典小项目（PWM、串口、音乐、以太网）的原理讲解。

## 四、视频课程
- **Shawn Hymel —— Introduction to FPGA**（YouTube 播放列表，Digi-Key 出品，开源工具友好，非常适合入门）
- **Nandland 频道** / **FPGAs for Beginners 频道**

## 五、开源工具链与生态
- **[YosysHQ/oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build)** —— 一站式开源 EDA 套件（yosys/nextpnr/iverilog/verilator/gtkwave/icestorm），解压即用。
- **[Icarus Verilog](https://steveicarus.github.io/iverilog/)** / **[Verilator](https://www.veripool.org/verilator/)** / **[GTKWave](https://gtkwave.sourceforge.net/)**
- **[Project IceStorm](https://clifford.at/icestorm)** —— Lattice iCE40 全开源烧录流程。

## 六、参考用 IP / 大型开源项目（进阶阅读）
- **[alexforencich/verilog-ethernet](https://github.com/alexforencich/verilog-ethernet)** —— 高质量以太网 MAC，工业级代码风格范本。
- **[ZipCPU](https://github.com/ZipCPU)** 系列 + [zipcpu.com 博客](https://zipcpu.com/) —— 形式化验证、总线、CPU，深入硬核。
- **[PicoRV32](https://github.com/YosysHQ/picorv32)** / **[VexRiscv](https://github.com/SpinalHDL/VexRiscv)** —— 可综合的 RISC-V 软核，想在 FPGA 里跑 CPU 时看。
- **[litex-hub / LiteX](https://github.com/enjoy-digital/litex)** —— 用 Python 快速搭 SoC 的框架。

## 七、书籍
- 《Digital Design and Computer Architecture》(Harris & Harris) —— 数字设计 + 体系结构，配套 HDLBits 风格练习，软件背景友好。
- 《FPGA Prototyping by Verilog Examples》(Pong P. Chu) —— 大量上板实例（VGA、UART、PS2 等）。
- 《Verilog HDL》(Samir Palnitkar) —— Verilog 语言系统参考。

## 八、给软件工程师的"亲切"路线（可选）
如果你更喜欢用软件语言生成硬件：
- **[Amaranth HDL](https://github.com/amaranth-lang/amaranth)**（Python）
- **[SpinalHDL](https://github.com/SpinalHDL/SpinalHDL)** / **[Chisel](https://www.chisel-lang.org/)**（Scala）
> 建议：仍先用 Verilog 把"硬件思维"打牢（理解会被综合成什么），再用这些高级框架提效。
