# 运行方法与调试方法

本仓库所有案例都遵循统一的运行接口。掌握这一套，你就能跑通/调试任何一个案例。

## 一、运行方法

### 跑单个案例
```bash
cd src/basics/01_hello_verilog
make            # 编译 + 仿真，控制台打印 [ OK ]/[PASS]
make wave       # 用 GTKWave 打开波形
make lint       # verilator 静态检查
make clean      # 清理生成文件
```

### 一键跑全部案例
```bash
# 仓库根目录
make test       # 依次跑所有案例，汇总通过/失败
make lint       # 对所有设计做静态检查
make list       # 列出所有案例目录
make clean      # 清理全部
```

### 手动跑（理解底层在做什么）
```bash
# 1) 编译：把设计 + testbench 编成可执行的仿真程序
iverilog -g2012 -Wall -o sim.vvp design.v design_tb.v
# 2) 运行：执行仿真，产生波形 .vcd
vvp sim.vvp
# 3) 看波形
gtkwave design_tb.vcd
```
`-g2012` 启用 SystemVerilog-2012 语法；`-Wall` 打开告警。

## 二、三种调试手段

### 1. 波形调试（最常用）
testbench 里加：
```verilog
initial begin
    $dumpfile("xxx_tb.vcd");   // 波形输出文件
    $dumpvars(0, xxx_tb);      // 0 = 递归 dump 该模块下所有信号
end
```
然后 `make wave` 打开 GTKWave：
- 左侧选模块 → 把信号拖到波形区
- 关注：时钟边沿处信号如何变化、复位是否生效、状态机状态转移
- 总线信号可右键改成十六进制/有符号显示
- GTKWave 小技巧：`Ctrl+F` 跳到信号变化处；保存 `.gtkw` 布局下次直接复用

### 2. 打印调试
```verilog
$display("Time=%0t state=%0d data=0x%02h", $time, state, data);  // 即时打印一次
$monitor("clk=%b q=%b", clk, q);   // 任一参数变化就自动打印（整个仿真只需一条）
```
常用格式：`%b` 二进制、`%d` 十进制、`%h` 十六进制、`%0t` 时间、`%0s` 字符串。
> 注意：Icarus Verilog 的 `$display` 对中文支持不好，**控制台输出请用 ASCII**（本仓库统一如此）。

### 3. 静态检查（lint）
```bash
verilator --lint-only -Wall design.v
```
能在仿真前就抓出：位宽不匹配、未驱动信号、意外锁存器、敏感列表遗漏等。

## 三、自校验 testbench（本仓库的统一约定）

每个案例的 testbench 都会**自动判定对错**，而不是让你肉眼看波形：
```verilog
task check(input [3:0] got, input [3:0] exp, input [255:0] name);
    if (got !== exp) begin errors = errors + 1; $display("[FAIL] %0s ...", name); end
    else             $display("[ OK ] %0s", name);
endtask
...
if (errors == 0) $display("[PASS] ...");
else begin $display("[FAIL] ..."); $fatal(1); end   // $fatal 让仿真以错误退出，CI 可感知
```
- 成功 → 打印 `[PASS]`；失败 → 打印 `[FAIL]` 并 `$fatal`。
- `make test` 和 CI 就是靠 grep `[PASS]`/`[FAIL]` 判定整体结果。

## 四、仿真时序的两个关键纪律

1. **不要在时钟沿瞬间采样/改激励**。非阻塞赋值 `<=` 在时钟沿后才生效，所以：
   - 检查信号：在 `@(posedge clk); #1;`（延后一点）之后再读，读到的是更新后的值。
   - 施加激励：常用 `@(negedge clk)` 改输入，保证下个上升沿稳定采样。
   （FSM、UART 案例的 README 有真实踩坑记录。）

2. **给等待加超时**。`while (!done) @(posedge clk);` 一旦设计有 bug 会死等，应加计数器超时并报 `[FAIL]`，避免仿真挂死。

## 五、上板调试（进阶）
- **ILA / SignalTap**：厂商提供的"片上逻辑分析仪"，把真实运行时的信号抓回来看波形（相当于硬件版断点）。
- 先用 LED/数码管输出关键状态，是最朴素但有效的上板调试法。
- 永远遵循：**先仿真通过，再上板**。
