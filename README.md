# Study FPGA

FPGA 学习笔记、代码示例与仿真项目，从零开始掌握数字逻辑设计与硬件描述语言。

## 学习路线

| 阶段 | 内容 | 目录 |
|------|------|------|
| 基础 | Verilog 语法、组合逻辑、时序逻辑 | `src/basics/` |
| 进阶 | 状态机、接口协议、模块化设计 | `src/intermediate/` |
| 高级 | DSP、高速接口、综合优化 | `src/advanced/` |

## 环境要求

- **仿真器**: [Icarus Verilog](https://steveicarus.github.io/iverilog/) + GTKWave
- **综合工具**: Xilinx Vivado / Intel Quartus (按需)
- **开发板**: 推荐 Digilent Basys 3 / Nexys A7 (Xilinx Artix-7)

## 快速开始

```bash
# 编译并运行第一个示例
cd src/basics/01_hello_verilog
iverilog -o hello_tb.vvp hello.v hello_tb.v
vvp hello_tb.vvp
gtkwave hello_tb.vcd
```

## 目录结构

```
study_fpga/
├── docs/           # 学习笔记与参考资料
├── src/            # 源码
│   ├── basics/     # 基础示例
│   ├── intermediate/ # 进阶项目
│   └── advanced/   # 高级专题
├── simulations/    # 仿真波形与测试平台
└── tools/          # 辅助脚本
```

## 贡献

见 [CONTRIBUTING.md](CONTRIBUTING.md)。
