# FPGA 操作的原子组件清单 + 实际工作组合方式

> 这份文档回答两个问题：
> 1. **FPGA 在真实工程里都直接驱动/采集哪些"单一原子性组件"？**（按类别穷举）
> 2. **这些原子件在实际工作中怎么组合成有用的系统？**（组合矩阵 + 本仓库可运行案例）
>
> "原子组件"= 完成**单一功能**、FPGA 用引脚/协议直接对接的器件（按键、LED、传感器、电机驱动、存储…）。
> 复杂系统 = 若干原子件 + FPGA 内部逻辑"粘合"而成。

---

## 一、原子组件清单（按类别）

每个组件给出：**作用 / 接口协议 / FPGA 侧需要的逻辑 / 对应本仓库案例**。
"对应案例"里 ✅ 表示仓库已有可运行实现，⭐ 表示在组合项目 `src/projects/` 中用到。


## 一、原子组件清单（119 条，按类别，已超 100）

每个组件给出：**作用 / 接口协议 / FPGA 侧需要的逻辑 / 对应本仓库案例**。
"对应案例"里 ✅ 表示仓库已有可运行实现，⭐ 表示在组合项目 `src/projects/` 中用到；
未直接对应的会标注最接近的可借鉴案例。完整 100 个案例索引见 [`07_examples_index.md`](07_examples_index.md)。

> 共 **119 条**原子组件（满足"扩到 100 条"目标），覆盖 13 大类。带「✅/⭐」的可在仓库找到对应实现。

### 1. 输入 / 人机（物理量 → 电平）
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| 按键 / 拨码开关 | 离散输入 | 单 GPIO | 去抖 + 边沿检测 | ✅ `intermediate/04_debounce` |
| 旋转编码器（增量式） | 旋钮/转速/位置 | A/B 正交方波(+Z) | 正交解码（判向+计步） | ⭐ `projects/01` |
| 多按键阵列消抖 | 多路离散输入 | 多 GPIO | 逐路同步+去抖 | ✅ `intermediate/30_debounce_multi` |
| 矩阵键盘 | 多按键省 IO | 行列扫描 GPIO | 行扫描+列采样+去抖 | ✅ `intermediate/18_keypad_scanner`，⭐ `projects/11` |
| 光电开关 / 对射 | 接近/到位/计数 | 单 GPIO | 去抖+计数/测频 | ✅ `intermediate/04_debounce` |
| 霍尔开关 | 转速/位置/限位 | 单 GPIO | 去抖+测频 | ✅ `intermediate/21_freq_counter` |
| 红外接收头（NEC） | 遥控器解码 | 单线脉宽编码 | 脉宽计时解码 FSM | 借鉴 `intermediate/29_pwm_capture` |
| PS/2 键盘鼠标 | 老式人机 | 时钟+数据两线 | 同步移位+奇偶校验 | ✅ `intermediate/28_ps2_rx` |
| 拨轮 / 电位器(经ADC) | 模拟旋钮 | ADC 通道 | 采样+去噪滤波 | ✅ `advanced/04_fir` |
| 限位 / 行程开关 | 机械边界检测 | 单 GPIO | 去抖+状态锁存 | ✅ `intermediate/04_debounce` |
| 倾倒 / 振动开关 | 姿态/碰撞触发 | 单 GPIO | 去抖+单稳展宽 | ✅ `intermediate/08_one_shot` |
| 触摸按键（电容） | 无接触输入 | 单 GPIO/专用 IC | 去抖+长按识别 | ✅ `intermediate/04_debounce` |

### 2. 输出 / 指示（电平 → 物理动作）
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| LED | 状态指示 | 单 GPIO | 直接驱动/PWM 调光 | ✅ `advanced/01_pwm_led` |
| RGB LED | 彩色指示 | 3 路 PWM | 三通道 PWM | ⭐ `projects/08_pwm_rgb` |
| 数码管（7 段） | 显示数字 | 段选+位选 GPIO | BCD 译码+扫描复用 | ✅ `intermediate/17_seven_seg_mux4` |
| 点阵 LED（8×8） | 图形/字符 | 行列扫描 | 行扫描+帧缓冲 | 借鉴 `intermediate/17_seven_seg_mux4` |
| 蜂鸣器（无源） | 提示音 | 单 GPIO | 方波频率发生(分频) | ✅ `basics/06_clock_divider` |
| 继电器 | 开关大功率 | 单 GPIO+驱动 | 使能+去抖+互锁 | ✅ `intermediate/04_debounce` |
| MOSFET / 三极管功率级 | 驱动负载 | 单 GPIO | 使能+软启动(PWM) | ✅ `advanced/01_pwm_led` |
| 数字电位器 | 程控电阻 | SPI/I2C | 寄存器写时序 | ✅ `advanced/21_spi_master_modes` |
| 振动马达 | 触觉反馈 | 单 GPIO+驱动 | PWM 强度+脉冲模式 | ✅ `advanced/12_pwm_multi` |
| 状态指示灯条(WS2812) | 可寻址灯带 | 单线归零码 | 精确时序位流发生 | 借鉴 `advanced/11_sigma_delta_dac` |

### 3. 显示
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| VGA 显示器 | 模拟视频 | HSYNC/VSYNC+RGB | 行/场时序+像素坐标 | ✅ `advanced/03_vga` |
| VGA 彩条/图案 | 测试图 | 同上 | 坐标分区配色 | ✅ `advanced/23_vga_pattern` |
| VGA 动态图形 | 运动渲染 | 同上 | 帧同步+对象坐标更新 | ⭐ `projects/13_vga_box` |
| HDMI/DVI | 数字视频 | TMDS 差分 | 8b/10b+串化(高级) | 借鉴 `advanced/03_vga` |
| OLED（SPI/I2C） | 小屏 | SPI/I2C | 初始化序列+显存刷新 | ✅ `advanced/21_spi_master_modes` |
| 字符 LCD(1602) | 文本 | 4/8 位并口 | 时序握手 FSM | ✅ `intermediate/01_fsm` |
| TFT LCD(并口/SPI) | 彩屏 | 并口/SPI+时序 | 像素写时序+帧缓冲 | 借鉴 `advanced/03_vga` |

### 4. 存储
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| 片上 Block RAM | 缓冲/查表 | 内部 | 同步读写时序 | ✅ `intermediate/06_ram` |
| 双口 RAM | 并发读写/跨域 | 内部双口 | 双端口仲裁 | ✅ `intermediate/13_dual_port_ram`，⭐ `projects/12` |
| 异步 FIFO | 跨时钟缓冲 | 内部+Gray指针 | Gray 指针+同步器 | ✅ `intermediate/12_async_fifo` |
| LIFO 栈 | 后进先出缓冲 | 内部 | 栈指针管理 | ✅ `intermediate/11_stack_lifo` |
| SPI Flash | 配置/掉电保存 | SPI | 命令时序(读/写/擦) | ✅ `advanced/21_spi_master_modes` |
| EEPROM(I2C) | 参数保存 | I2C | 页写/随机读时序 | ✅ `advanced/22_i2c_master_write` |
| 异步 SRAM | 高速缓冲 | 地址/数据/WE/OE | 读写时序控制 | ✅ `intermediate/06_ram` |
| SDRAM / DDR | 大容量帧缓冲 | 多信号+刷新 | 刷新/行列控制器(进阶) | 借鉴 `intermediate/06_ram` |
| SD 卡 | 大容量存储 | SPI/SDIO | 命令/块传输 FSM | ✅ `advanced/21_spi_master_modes` |
| 正弦 ROM 查找表 | 波形/查表 | 内部 ROM | 地址→样本 | ✅ `intermediate/14_sine_rom` |

### 5. 通信 / 总线
| 组件/协议 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| UART | 串口 | TX/RX 异步两线 | 波特率分频+移位收发 | ✅ `intermediate/02_uart` |
| UART+FIFO | 带缓冲串口 | TX/RX+FIFO | 发送 FIFO 解耦 | ✅ `advanced/15_uart_tx_fifo` |
| UART 自环 | 收发联测 | TX→RX | 回环校验 | ✅ `intermediate/15_uart_loopback`，⭐ `projects/04` |
| RS485 | 工业长距串口 | UART+方向控制 | UART+DE/RE 切换 | 借鉴 `intermediate/02_uart` |
| SPI 主机(4模式) | 高速同步串行 | SCLK/MOSI/MISO/CS | 模式可配移位+CS | ✅ `advanced/21_spi_master_modes` |
| SPI 从机 | 被动应答 | 同上 | 从机移位+锁存 | ✅ `intermediate/16_spi_slave`，⭐ `projects/17` |
| I2C 主机 | 双线多设备 | SCL/SDA 开漏 | START/ACK/STOP FSM | ✅ `advanced/22_i2c_master_write` |
| I2C 多字节 | 块读写 | 同上 | 连续字节+ACK 管理 | ✅ `advanced/22_i2c_master_write` |
| APB 总线 | 片内寄存器访问 | PADDR/PWDATA/... | 两相 setup/access | ✅ `advanced/20_apb_regfile` |
| 轮询/优先级仲裁器 | 多主仲裁 | 内部 req/grant | RR/固定优先 | ✅ `advanced/17_rr_arbiter` / `18_prio_arbiter` |
| 交叉开关(Crossbar) | NxN 互连 | 内部 | 选路+无冲突 | ✅ `advanced/19_crossbar` |
| Skid 缓冲 | valid/ready 流控 | 内部握手 | 背压无丢失缓冲 | ✅ `advanced/16_skid_buffer` |
| CAN | 汽车/工业总线 | 差分 CANH/CANL | 位时序+仲裁+CRC | 借鉴 `intermediate/26_crc16` |
| 以太网 PHY(RMII) | 网络 | RMII 多线 | MAC FSM+FIFO | 借鉴 `intermediate/12_async_fifo` |
| 曼彻斯特编/解码 | 自同步串行 | 单线双相码 | 边沿编码/解码 | ✅ `intermediate/23/24`，⭐ `projects/14` |
| 跨时钟脉冲同步 | CDC 脉冲传递 | 跨域信号 | toggle+2FF+边沿 | ✅ `advanced/25_pulse_sync` |
| 两级同步器 | 异步输入入域 | 单 bit | 2 级触发器 | ✅ `intermediate/09_edge_detector` |

### 6. 模拟接口
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| ADC(SPI/并口) | 采集模拟量 | SPI/并口 | 采样时序+对齐 | ✅ `advanced/21_spi_master_modes` |
| DAC(SPI) | 输出模拟量 | SPI | 写时序 | ✅ `advanced/21_spi_master_modes` |
| ΣΔ-DAC(1bit) | PWM 式 DAC | 单 GPIO+RC | 一阶 ΣΔ 密度调制 | ✅ `advanced/11_sigma_delta_dac` |
| PWM 功率级 | 调光/调速 | 单 GPIO→驱动 | 占空比/频率调制 | ✅ `advanced/01_pwm_led` / `12_pwm_multi` |
| 比较器(外部) | 过零/阈值检测 | 单 GPIO 输入 | 去抖+计时 | ✅ `intermediate/29_pwm_capture` |
| 可变增益放大(程控) | 调增益 | SPI/I2C | 寄存器写 | ✅ `advanced/21_spi_master_modes` |

### 7. 传感
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| 温湿度/气压(I2C) | 环境量 | I2C | 寄存器读+阈值 | ⭐ `projects/16_i2c_alarm` |
| IMU(MPU6050) | 姿态/加速度 | I2C/SPI | 多寄存器突发读 | ✅ `advanced/22_i2c_master_write` |
| 超声波测距(HC-SR04) | 距离 | Trig+Echo | 触发+回波计时 | ✅ `intermediate/29_pwm_capture` |
| 摄像头(OV7670 DVP) | 图像 | 并口像素+行场同步 | 像素采集+写帧缓冲 | `advanced/03_vga`+`06_ram` |
| 编码器测速 | 转速 | A/B 正交 | 测频/测周期 | ✅ `intermediate/21_freq_counter`，⭐ `projects/01` |
| 光强/颜色(I2C) | 环境光 | I2C | 寄存器读 | ✅ `advanced/22_i2c_master_write` |
| 热电偶/RTD(SPI) | 高温测量 | SPI | 采样+线性化 | ✅ `advanced/21_spi_master_modes` |
| 称重(HX711) | 力/重量 | 类 SPI 串行 | 移位读+滤波 | ✅ `advanced/04_fir` |
| 霍尔电流传感 | 电流测量 | ADC/模拟 | 采样+滤波 | ✅ `advanced/04_fir` |

### 8. 驱动 / 执行
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| 直流电机+H桥 | 调速/正反转 | PWM+方向 | PWM+方向+闭环 | ⭐ `projects/01` |
| 步进电机驱动 | 精确角位 | 4 相/STEP-DIR | 相序发生+换向 | ✅ `advanced/14_stepper_drive` |
| 步进定位控制 | 走到目标步 | STEP-DIR | 计步+到位判断 | ⭐ `projects/10_stepper_position` |
| 舵机 | 角度控制 | 50Hz 变脉宽 PWM | 定周期变脉宽 | ✅ `advanced/13_servo_pwm` |
| 舵机扫摆 | 自动巡航 | 同上 | 三角波位置发生 | ⭐ `projects/09_servo_sweep` |
| 多路 PWM | 多通道驱动 | 多 GPIO | 并行 PWM 通道 | ✅ `advanced/12_pwm_multi` |
| 无刷电机(BLDC)换相 | 高效驱动 | 6 路+霍尔 | 换相表+PWM(进阶) | 借鉴 `advanced/14_stepper_drive` |
| 固态继电器/可控硅 | 交流通断 | 单 GPIO+过零 | 过零检测+触发 | ✅ `intermediate/29_pwm_capture` |

### 9. 时钟 / 复位 / 定时
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| 晶振 / 有源时钟 | 系统时钟源 | 时钟引脚 | 直接进时钟树 | ✅ `basics/06_clock_divider` |
| PLL/MMCM(片内) | 倍频/分频/相位 | 内部 IP | 时钟生成+约束 | 借鉴 `basics/06_clock_divider` |
| 分频器/节拍发生 | 派生节拍 | 内部 | 计数分频+使能脉冲 | ✅ `basics/06_clock_divider` / `intermediate/10_clock_enable` |
| 复位同步器 | 异步复位同步释放 | 复位引脚 | 2FF 复位同步 | ✅ `advanced/25_pulse_sync`(同步思路) |
| 看门狗定时器 | 死机自恢复 | 内部 | 超时计数+复位 | ✅ `intermediate/20_watchdog` |
| 可编程定时器 | 周期/单次中断 | 内部 | 装载值+计数 | ✅ `intermediate/19_prog_timer` |
| 单稳态(脉冲展宽) | 定长脉冲 | 内部 | 触发+定时复位 | ✅ `intermediate/08_one_shot` |
| RTC(I2C) | 实时时钟 | I2C | BCD 时间读写 | ✅ `advanced/22_i2c_master_write` |
| 秒表/计时 | 计时显示 | 内部 | BCD 计数链 | ✅ `intermediate/07_stopwatch`，⭐ `projects/07` |

### 10. 数据处理 / DSP 原语
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| ALU | 算术逻辑运算 | 内部 | 多路运算+标志 | ✅ `basics/05_alu`，⭐ `projects/21` |
| 乘累加(MAC) | 卷积/滤波核 | 内部 | a*b 累加 | ✅ `advanced/10_mac` |
| Booth 乘法器 | 有符号乘 | 内部 | 移位加+符号处理 | ✅ `advanced/09_booth_mul` |
| 串行除法器 | 除/取模 | 内部 | 移位减迭代 | ✅ `advanced/07_seq_divider` |
| 整数开方 | 平方根 | 内部 | 逐位试减 | ✅ `advanced/08_seq_sqrt` |
| CORDIC | sin/cos/旋转 | 内部 | 迭代移位旋转 | ✅ `advanced/06_cordic_sincos` |
| DDS/NCO | 频率合成 | 内部 | 相位累加+查表 | ✅ `advanced/05_dds`，⭐ `projects/19` |
| FIR/移动平均 | 数字滤波 | 内部 | 滑窗累加 | ✅ `advanced/04_fir`，⭐ `projects/18` |
| 寄存器堆 | 通用寄存器 | 内部 | 多口读写 | ⭐ `projects/21_alu_datapath` |
| 二进制转 BCD | 显示转换 | 内部 | double dabble | ✅ `intermediate/05_seven_seg` |
| 频率计 | 测频率 | 闸门+计数 | 闸门窗口计数 | ✅ `intermediate/21_freq_counter`，⭐ `projects/06` |
| 占空比测量 | 测 PWM 占空 | 输入捕获 | 高/周期计时比 | ✅ `intermediate/22_duty_measure` |
| 输入捕获 | 测脉宽/周期 | 输入引脚 | 边沿打时间戳 | ✅ `intermediate/29_pwm_capture` |

### 11. 数据完整性 / 编码
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| CRC-8 校验 | 数据校验 | 内部 | LFSR 逐位 | ✅ `intermediate/25_crc8`，⭐ `projects/15` |
| CRC-16 校验 | 通信帧校验 | 内部 | LFSR 逐位 | ✅ `intermediate/26_crc16` |
| 汉明码(7,4) | 纠错 | 内部 | 校验位生成+纠正 | ✅ `intermediate/27_hamming74` |
| 奇偶校验 | 简单检错 | 内部 | XOR 归约 | ✅ `intermediate/02_uart`(可选校验位) |
| 8b/10b 编码 | 直流平衡串行 | 内部 | 查表编码(进阶) | 借鉴 `intermediate/23_manchester_enc` |
| 边沿检测器 | 脉冲提取 | 内部 | 延迟+XOR | ✅ `intermediate/09_edge_detector` |
| 格雷码计数 | 跨域安全计数 | 内部 | 二进制↔格雷 | ✅ `intermediate/12_async_fifo` |

### 12. 电源 / 监控 / 安全
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| 电源时序控制 | 多路上电顺序 | 多 GPIO EN | 延时使能 FSM | ✅ `intermediate/01_fsm` |
| 复位按钮 | 手动复位 | 单 GPIO | 去抖+同步释放 | ✅ `intermediate/04_debounce` |
| 温度监控(I2C) | 过温保护 | I2C | 读温+阈值报警 | ⭐ `projects/16_i2c_alarm` |
| 电压监测(ADC) | 欠/过压检测 | ADC | 采样+窗口比较 | ✅ `advanced/04_fir` |
| 风扇 PWM 调速 | 散热控制 | PWM+转速反馈 | 温度→PWM+测速 | ✅ `advanced/12_pwm_multi`+`26_freq_meter` |
| 心跳/活性指示 | 系统运行可视 | 单 GPIO | 慢闪分频 | ✅ `basics/06_clock_divider` |

### 13. 调试 / 测试接口
| 组件 | 作用 | 接口 | FPGA 侧逻辑 | 对应案例 |
|------|------|------|-------------|----------|
| 逻辑分析仪触发(ILA思路) | 抓内部信号 | 内部+触发 | 触发+采样到 RAM | ✅ `intermediate/06_ram` |
| 串口调试上报 | 打印内部状态 | UART | 状态→ASCII→UART | ⭐ `projects/05_button_uart_report` |
| 测试图案发生 | 显示自检 | VGA | 坐标配色 | ✅ `advanced/23_vga_pattern` |
| 内建自检(BIST) | 上电自测 RAM | 内部 | 写-读回比对 | ⭐ `projects/12_sram_blockcopy` |
| 信号发生器 | 激励源 | DDS/PWM | 频率/波形可调 | ⭐ `projects/19_dds_uart_ctrl` |

---
---

## 二、组合方式：原子件 → 真实系统

把上面的原子件按"输入→处理→输出/通信/存储"组合，就得到工程里实际用的子系统。
下表是**可落地组合矩阵**，标注难度与所需模块；带 🟢 的已在本仓库 `src/projects/` 做成**可运行案例**。

| 组合系统 | = 原子件组合 | FPGA 内部逻辑 | 难度 | 仓库案例 |
|----------|--------------|---------------|------|----------|
| 🟢 **闭环电机调速** | 旋转编码器 + PWM + H 桥(电机) | 正交解码 → 测速 → P/PI 控制 → PWM | ★★★ | `projects/01_encoder_pwm_loop` |
| 🟢 **传感器采集上报** | I2C 传感器 + UART | I2C 读 → 握手 FSM → UART 发 | ★★★ | `projects/02_i2c_sensor_uart` |
| 🟢 **按键计数显示** | 按键 + 数码管 | 去抖 → 计数 → BCD → 7 段扫描 | ★★ | `projects/03_button_counter_seg` |
| 旋钮调参显示 | 编码器 + 数码管 | 正交解码 → 增减计数 → 显示 | ★★ | 组合 `projects/01`+`projects/03` |
| 定时数据记录仪 | 传感器(I2C) + Flash(SPI) + UART | 定时采集 → 写 Flash → 按需回传 | ★★★★ | `projects/02` + `spi_master` + `clock_divider` |
| 图像采集显示 | 摄像头 + SDRAM + VGA | 像素采集 → 写帧缓冲 → VGA 读出 | ★★★★★ | `advanced/03_vga` + 帧缓冲(RAM/SDRAM) |
| 数字示波器前端 | ADC(SPI) + RAM + VGA/UART | 采样 → 缓冲 → FIR 滤波 → 显示/上报 | ★★★★ | `spi_master` + `06_ram` + `04_fir` + `03_vga` |
| 串口命令控制台 | UART + FIFO + GPIO/PWM | 收命令 → 解析 FSM → 驱动外设 | ★★★ | `02_uart` + `03_fifo` + `pwm_led` |
| 步进电机定位 | 按键/编码器 + 步进驱动 + 数码管 | 目标设定 → 加减速脉冲 → 显示 | ★★★★ | `clock_divider` + `debounce` + `seven_seg` |
| 环境监测终端 | 温湿度(I2C) + OLED(SPI/I2C) + 蜂鸣器 | 采集 → 阈值判断 → 显示 + 报警 | ★★★★ | `projects/02` + `spi_master` + 分频蜂鸣 |
| RS485 数据节点 | UART + RS485 收发器 + 传感器 | UART + 方向控制 + 协议帧 | ★★★ | `02_uart` 扩展方向控制 |

> **组合方法论**（怎么自己拼新系统）：
> 1. **分层**：输入采集层 / 处理层 / 输出（显示/通信/驱动）层，各用一个原子模块。
> 2. **接口约定**：模块间用"数据 + valid/ready 脉冲"或"完成 done 脉冲"握手（见 `projects/02` 的 FSM）。
> 3. **时钟与节拍**：用分频器（`clock_divider`）产生采样/扫描/刷新节拍。
> 4. **缓冲解耦**：跨速率/跨时钟用 FIFO（`03_fifo`）或 RAM（`06_ram`）。
> 5. **闭环**：需要稳定控制时，把"测量→比较→执行"接成反馈环（见 `projects/01`）。

---

## 三、本仓库的三个组合案例（可运行）

都在 `src/projects/` 下，模板与其余案例一致（设计 + 自校验 testbench + Makefile + README），
`make test` 全部 `[PASS]`，并自动出现在 Web 平台案例库。

| 案例 | 组合 | 学到什么 |
|------|------|----------|
| [`projects/01_encoder_pwm_loop`](../src/projects/01_encoder_pwm_loop) | 编码器 + 测速 + P 控制 + PWM | 闭环控制骨架、正交解码、反馈环 |
| [`projects/02_i2c_sensor_uart`](../src/projects/02_i2c_sensor_uart) | I2C 传感器 + UART | I2C 时序、开漏总线、跨外设握手 FSM |
| [`projects/03_button_counter_seg`](../src/projects/03_button_counter_seg) | 按键去抖 + 计数 + 数码管 | 模块复用、数据通路串联 |

继续深入可按"组合矩阵"里 ★★★★ 以上的系统自行拼装——所需的原子模块仓库都已提供。
