# 01 · Hello Verilog —— 4 位计数器

第一个 FPGA "Hello World"：一个每个时钟上升沿自增、可异步复位的 4 位计数器。

## 这一课学什么
- 模块（`module`）= 一块硬件电路，端口（`input/output`）= 引脚
- **时序逻辑**：`always @(posedge clk)` —— 在时钟边沿更新寄存器
- **非阻塞赋值** `<=` —— 时序逻辑里描述"同时更新"的标准写法
- **异步复位**：`negedge rst_n` 进入敏感列表，复位优先于时钟
- 4 位会**自动回绕**（15 → 0），这是硬件位宽的天然行为

> 软件类比：这不是一个"循环 +1"的程序，而是 16 个触发器组成的寄存器，每来一个时钟脉冲，组合逻辑把 `count+1` 算好、在边沿"拍"进寄存器。没有 CPU、没有指令——电路本身就是计数器。

## 文件
| 文件 | 作用 |
|------|------|
| `hello.v` | 设计：`hello_counter` 模块 |
| `hello_tb.v` | 自校验 testbench（断言 + 波形） |
| `Makefile` | 仿真/波形/检查/清理 |

## 运行
```bash
make            # 编译 + 仿真，控制台打印 [ OK ]/[PASS]
make wave       # 用 GTKWave 打开 hello_tb.vcd 观察波形
make lint       # verilator 静态检查
make clean      # 清理生成文件
```

预期输出结尾：`[PASS] hello_counter: all assertions passed`

## 波形里看什么
- `clk` 方波；`rst_n` 拉低期间 `count` 恒为 0
- `rst_n` 拉高后，`count` 在每个 `clk` 上升沿 +1，到 15 后回到 0

## 动手改
1. 把 `count` 改成 8 位，回绕值会变成多少？
2. 增加一个 `input wire en`，只有 `en=1` 时才计数。
