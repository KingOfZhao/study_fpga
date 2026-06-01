# 21 · 微指令 ALU 数据通路 alu_datapath

寄存器堆 + ALU + 微指令控制：按指令序列做取操作数→运算→写回，是 CPU 的雏形。

## 这一课学什么
- 数据通路三件套：**寄存器堆**(存数) + **ALU**(算数) + **控制**(决定每拍干啥)
- 微指令：每条指令指定“源寄存器、运算、目的寄存器”
- 这正是 CPU 执行的本质——取数、运算、写回的循环

> 软件类比：像一个极简虚拟机——指令是 `(op, rs1, rs2, rd)`，每拍读两个“变量”、算一下、把结果存回另一个“变量”。把它扩出取指/译码就是真 CPU。

## 运行
```bash
make        # 跑一段微指令序列，校验寄存器堆最终值
make wave
make clean
```

## 上板玩法
- 软核 CPU 的内核雏形；理解后可对照真实 RISC-V 核。

## 动手改
1. 加“取指 + 译码”和程序计数器，做成最小可编程 CPU。
2. 加分支/内存访问指令。

## 对应真实开源项目
- 进阶到真实软核：[PicoRV32](https://github.com/YosysHQ/picorv32)、[VexRiscv](https://github.com/SpinalHDL/VexRiscv)、[SERV](https://github.com/olofk/serv)（最小 RISC-V）；ALU 见本仓 `basics/05_alu`。
