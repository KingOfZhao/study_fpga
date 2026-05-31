# Verilog 速查表

## 数据类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `wire` | 组合逻辑连线 | `wire [7:0] data;` |
| `reg` | 过程赋值存储 | `reg [3:0] counter;` |
| `integer` | 32位有符号整数 | `integer i;` |
| `parameter` | 常量参数 | `parameter WIDTH = 8;` |

## 运算符

| 类型 | 运算符 |
|------|--------|
| 算术 | `+`, `-`, `*`, `/`, `%` |
| 位运算 | `~`, `&`, `\|`, `^` |
| 移位 | `<<`, `>>`, `<<<`, `>>>` |
| 关系 | `>`, `<`, `>=`, `<=`, `==`, `!=` |
| 逻辑 | `&&`, `\|\|`, `!` |
| 拼接 | `{a, b, c}` |
| 重复 | `{4{bit}}` |

## 过程块

```verilog
// 组合逻辑
always @(*) begin
    // 敏感列表为 * 表示所有输入
end

// 时序逻辑（同步）
always @(posedge clk) begin
    // 仅在时钟上升沿触发
end

// 异步复位 + 同步时序
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        // 复位逻辑
    else
        // 正常逻辑
end
```

## 赋值方式

| 方式 | 用途 | 特性 |
|------|------|------|
| `=` | 阻塞赋值 | 顺序执行，用于 `initial` / `always @(*)` |
| `<=` | 非阻塞赋值 | 并行执行，用于 `always @(posedge clk)` |

## 模块与端口

```verilog
module my_mod #(
    parameter WIDTH = 8           // 参数（编译期常量）
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] dout
);
    // ... 实现 ...
endmodule

// 例化（实例化）—— 用命名端口连接，别用位置连接
my_mod #(.WIDTH(16)) u_inst (
    .clk(clk), .rst_n(rst_n), .din(din), .dout(dout)
);
```

## 字面量与位宽

```verilog
4'b1010     // 4 位二进制
8'hFF       // 8 位十六进制
8'd200      // 8 位十进制
1'b0        // 单比特
{4{1'b1}}   // 重复拼接 = 4'b1111
{a, b}      // 拼接
```
注意：固定位宽会**回绕/截断**，例如 `4'd15 + 1'b1 == 4'd0`。

## 常用电路模板

```verilog
// 计数器（带使能）
always @(posedge clk or negedge rst_n)
    if (!rst_n)      cnt <= 0;
    else if (en)     cnt <= cnt + 1'b1;

// 三段式 FSM
reg [1:0] state, next;
always @(posedge clk or negedge rst_n)         // 1) 状态寄存器
    if (!rst_n) state <= S0; else state <= next;
always @(*) begin                               // 2) 次态逻辑
    next = state;
    case (state) S0: if (go) next = S1; /*...*/ endcase
end
always @(*) begin /* 3) 输出逻辑，按 state 译码 */ end

// 分频/慢时钟使能（不要再生成新时钟，用使能脉冲）
always @(posedge clk)
    if (div == N-1) begin div <= 0; tick <= 1'b1; end
    else            begin div <= div + 1; tick <= 1'b0; end
```

## testbench 常用系统任务

```verilog
`timescale 1ns/1ps
initial begin
    $dumpfile("tb.vcd"); $dumpvars(0, tb);  // 生成波形
end
always #5 clk = ~clk;                        // 时钟
$display("a=%b h=%0h d=%0d t=%0t", a, h, d, $time); // 打印一次
$monitor(...);   // 任一变量变化即打印
#10;             // 延时 10 个时间单位
@(posedge clk);  // 等上升沿
$finish;         // 结束仿真
$fatal(1);       // 以错误退出（CI 可感知）
```

## `==` vs `===`
- `==`/`!=`：若含 x/z 结果为 x（不可靠）。
- `===`/`!==`：**全等比较**，能区分 0/1/x/z，testbench 断言用它最稳。

## 常见坑速记
- 组合 `always @(*)` 每个分支都要给输出赋值，否则生成**意外锁存器**。
- 时序块用 `<=`，组合块用 `=`，别混用。
- testbench 改激励用 `@(negedge clk)`；读结果在 `@(posedge clk); #1;` 之后。
- 跨时钟域信号要过两级触发器同步。
