# 组合项目 03 · 按键计数数码管（去抖 + 计数 + BCD + 7段译码）

把前面学过的三个**原子组件**串成一条完整数据通路，做一个真实工程里随处可见的小系统：
**按一次键 → 计数 +1 → 十进制显示在数码管上**。

```
btn_in ──▶ [debounce 去抖+边沿] ──btn_rise──▶ [counter 计数器]
                                                   │ count[7:0]
                                                   ▼
                                          [bin2bcd 转 BCD] ──▶ huns/tens/ones
                                                   │
                                                   ▼
                                       [seg7 ×3 译码] ──▶ 三位段码（驱动数码管）
```

## 这一课学什么（组合的价值）
- **模块复用**：直接实例化 `debounce` / `bin2bcd` / `seg7` 三个已验证模块，不重写
- **数据通路串联**：上一个模块的输出就是下一个模块的输入，像搭积木
- **去抖的必要性**：没有去抖，机械按键一次按下会被计成好几次——本例 testbench 专门用"抖动"波形验证只 +1
- **悬空引脚**：只用 `debounce` 的 `btn_rise`，其余输出接到具名 wire 留空（lint 友好）

> 软件类比：像把几个纯函数/组件用管道连起来 `seg7(bin2bcd(count(debounce(btn))))`，但这里每一级都是**同时在跑的硬件**。

## 复用的原子组件
| 文件 | 来源案例 | 作用 |
|------|----------|------|
| `debounce.v` | `intermediate/04_debounce` | 按键去抖 + 上升沿脉冲 |
| `bin2bcd.v`  | `intermediate/05_seven_seg` | 二进制 → 百/十/个位 BCD |
| `seg7.v`     | `intermediate/05_seven_seg` | BCD → 共阳极 7 段码 |

## 运行
```bash
make            # 模拟带抖动的 12 次按下，校验精确计数 + 段码正确 → [PASS]
make wave       # 看 btn_in 抖动、btn_rise 单脉冲、count 阶梯上升
make lint
make clean
```

## 上板玩法
- `btn_in` 接开发板按键，三位 `seg_*` 接数码管段选，配一个扫描位选即可点亮（参考 `intermediate/05_seven_seg` 的扫描复用）。
- 把计数器换成"按住快速加、单按 +1"的混合逻辑。

## 动手改
1. 加一个复位按钮（再实例化一个 `debounce`，用它的脉冲清零 `count`）。
2. 加上 `intermediate/05_seven_seg` 的扫描复用，用单组段线分时驱动 3 位。
