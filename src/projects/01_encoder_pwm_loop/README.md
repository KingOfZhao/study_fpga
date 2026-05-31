# 组合项目 01 · 闭环电机调速（编码器 + 测速 + P 控制 + PWM）

把 4 个原子组件组合成工业里最经典的**闭环控制**回路：用编码器测出实际转速，
和目标比较，控制器据误差调整 PWM 占空比去驱动电机，转速随之改变——如此不断逼近目标。

```
            target（目标转速）
                 │
  enc_a/enc_b    ▼
  ──▶[quad_decoder]──tick──▶[speed_meter]──speed──▶[p_controller]──duty──▶[pwm]──▶ pwm_out
        编码器解码          固定窗口测速          比例(积分)控制       占空比     驱动 H桥/MOSFET
        │                                                                          │
        └────────────────────────── 反馈：转速被测量后回到控制器 ────────────────────┘
```

## 这一课学什么（系统级组合）
- **闭环 vs 开环**：开环只设占空比、不管实际转速；闭环用反馈自动校正负载/电压变化
- **正交编码器解码**：A/B 两路相位差 90°，由 `A_new ⊕ B` 判方向，A 边沿计步
- **测速**：固定时间窗口内数脉冲个数 = 转速（频率法）
- **比例/积分控制**：`duty += (target − speed) >> K`，只要有误差就持续修正，稳态误差趋于 0
- **定点与位宽规划**：误差在有符号域计算并钳位到合法占空比范围

> 软件类比：就是一个 PID 控制循环 `while(true){ measure(); err=set-meas; out+=Kp*err; drive(out);}`，
> 但这里每个环节都是**并行的硬件**，采样节拍由 `speed_meter` 的窗口决定。

## 模块清单
| 文件 | 作用 |
|------|------|
| `quad_decoder.v` | 正交编码器 → 步进脉冲 `tick` + 方向 `dir` |
| `speed_meter.v`  | 每 `WIN` 拍统计脉冲数 → `speed` + `sample` |
| `p_controller.v` | 按误差调占空比（积分式，带钳位） |
| `pwm.v`（复用 `advanced/01_pwm_led`） | 占空比 → PWM 方波 |
| `motor_speed_ctrl.v` | 顶层：把上面接成闭环 |

## 运行
```bash
make            # 测方向解码 + 闭环收敛（内置被控对象模型，speed≈duty）→ [PASS]
make wave       # 看 duty 逐窗口爬升、speed 收敛到 target 附近
make lint
make clean
```
testbench 里的"被控对象"用相位累加器模拟：编码器频率正比于 `duty`，因此实测 `speed≈duty`，
闭环会把 `duty` 调到使 `speed≈target`。

## 上板玩法
- `pwm_out` 经栅极驱动接 H 桥/MOSFET 驱动直流电机；`enc_a/enc_b` 接电机轴上的正交编码器。
- 调 `KSH`（增益）观察收敛快慢与超调；窗口 `WIN` 影响测速分辨率与响应速度。

## 动手改
1. 把积分式换成真正的 PI（再加一个积分项寄存器并限幅抗饱和）。
2. 用 `dir` 做正反转控制，目标速度带符号。
3. 把 `speed_meter` 改成"测周期"法（适合低速高分辨率）。
