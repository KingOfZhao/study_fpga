# 12 · RAM 块拷贝自检 sram_blockcopy

状态机把源区数据逐字拷到目的区，再回读比对，做存储自检(BIST)。

## 这一课学什么
- 控制状态机驱动存储读写：填充 → 拷贝 → 校验
- 注意同步 RAM 的**读延迟**（地址给出后下一拍才有数据）
- 内建自测试(BIST) 思路

> 软件类比：像 `dst = src.copy()` 后 `assert(dst == src)`——但要手动管理地址递增、读延迟和逐字搬运的时序。

## 运行
```bash
make        # 填充→拷贝→回读比对，全部一致则 [PASS]
make wave
make clean
```

## 上板玩法
- 上电存储自检；DMA 式块搬运的雏形。

## 动手改
1. 加典型 RAM 测试图样（走 0/走 1、棋盘）。
2. 改双口 RAM 让读写重叠提速。

## 对应真实开源项目
- 存储 BIST/March 测试见各 MBIST 资料；RAM 推断见本仓 `intermediate/13_dual_port_ram`、`intermediate/06_ram`。
