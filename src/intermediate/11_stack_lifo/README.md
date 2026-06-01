# 11 · 栈 stack_lifo

后进先出（LIFO）存储：push 压栈、pop 出栈，带 full/empty 标志，栈顶组合读出。

## 这一课学什么
- 用一块 RAM + 一个栈指针 `sp` 实现 LIFO
- full/empty 由 `sp` 边界产生，防止溢出/下溢
- 与 FIFO 对照：同是缓冲，但出队顺序相反

> 软件类比：就是 Dart 的 `List` 当栈用（`add`/`removeLast`）。区别是容量固定、push/pop 在时钟沿发生，full/empty 必须显式检查（没有动态扩容）。

## 运行
```bash
make        # 压满 8 个再弹出，校验 LIFO 顺序 8..1
make wave
make clean
```

## 上板玩法
- 表达式求值、递归/中断现场保存、撤销栈等场景的硬件雏形。

## 动手改
1. pop 的同时输出被弹出的值（当前为栈顶组合读出）。
2. 对照 `intermediate/01` 系列里的 FIFO，画出两者指针行为差异。

## 对应真实开源项目
- 栈是 CPU 调用约定/中断现场的基础；对照本仓 FIFO 案例理解两种缓冲语义。
