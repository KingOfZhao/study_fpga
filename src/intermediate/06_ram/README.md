# 06 · 片上 RAM（Block RAM 推断）

FPGA 内部有专门的存储块（Block RAM）。只要按**特定写法**描述，综合工具就会自动把你的数组映射成 BRAM，而不是用一堆触发器。本例是最常用的单端口同步 RAM。

## 这一课学什么
- **存储数组** `reg [DW-1:0] mem [0:DEPTH-1]`
- **同步读写**：读和写都发生在时钟沿；**注册输出**导致读数据延迟 1 拍——这是 BRAM 的固有特性，写代码和 testbench 都要考虑
- **读写同址策略**：本例为 read-first（读旧值）；换写法可得到 write-first / no-change
- 为什么不用组合读？组合读（`assign dout = mem[addr]`）会被综合成"分布式 RAM/LUT RAM"，容量小、浪费资源

> 软件类比：像一个数组，但**读它要等一个时钟**（`dout` 比 `addr` 晚一拍），且读写都得踩时钟节拍——不能像内存那样即取即得。

## 运行
```bash
make            # 写满 16 个地址再读回，断言数据一致（含 1 拍读延迟处理）
make wave       # 看 we/addr/din 写入、dout 延迟 1 拍输出
make lint
make clean
```

## 上板玩法
- 把它当查找表（ROM）：用 `$readmemh` 预载数据，只读不写。
- 和 FIFO（上一课进阶）对比：FIFO 就是在 RAM 外面包了读写指针 + 空满判断。

## 动手改
1. 改成**简单双口** RAM：一个写端口 + 一个独立读端口（各自地址），常用于跨模块缓冲。
2. 用 `$readmemh("init.hex", mem)` 在 `initial` 里预初始化，做一个正弦查找表 ROM。
