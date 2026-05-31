# 全部 100 个案例索引

> 自动汇总（按目录顺序）。根目录 `make test` 一键跑全部并汇总，`make list` 列出目录。
> 每个案例含：设计 `*.v` + 自校验 testbench `*_tb.v` + `Makefile` + `README.md`。

## 基础 basics（24 个）

| 案例 | 说明 |
|------|------|
| [`basics/01_hello_verilog`](../src/basics/01_hello_verilog) | 01 · Hello Verilog —— 4 位计数器 |
| [`basics/02_combinational`](../src/basics/02_combinational) | 02 · 组合逻辑 —— 全加器 |
| [`basics/03_mux_decoder`](../src/basics/03_mux_decoder) | 03 · MUX 与译码器 |
| [`basics/04_sequential`](../src/basics/04_sequential) | 04 · 时序逻辑 —— 触发器与移位寄存器 |
| [`basics/05_alu`](../src/basics/05_alu) | 05 · ALU —— 算术逻辑单元（组合逻辑进阶） |
| [`basics/06_clock_divider`](../src/basics/06_clock_divider) | 06 · 分频器 / 节拍发生器（时序逻辑进阶） |
| [`basics/07_half_adder`](../src/basics/07_half_adder) | 07 · 半加器 half_adder |
| [`basics/08_mux4_1`](../src/basics/08_mux4_1) | 08 · 4:1 多路选择器 mux4_1 |
| [`basics/09_demux1_4`](../src/basics/09_demux1_4) | 09 · 1:4 解复用器 demux1_4 |
| [`basics/10_priority_encoder`](../src/basics/10_priority_encoder) | 10 · 8:3 优先编码器 priority_encoder |
| [`basics/11_decoder3_8`](../src/basics/11_decoder3_8) | 11 · 3:8 译码器 decoder3_8 |
| [`basics/12_comparator4`](../src/basics/12_comparator4) | 12 · 4 位比较器 comparator4 |
| [`basics/13_parity`](../src/basics/13_parity) | 13 · 奇偶校验 parity |
| [`basics/14_gray_bin`](../src/basics/14_gray_bin) | 14 · 格雷码互转 gray_bin |
| [`basics/15_barrel_shifter`](../src/basics/15_barrel_shifter) | 15 · 桶形移位器 barrel_shifter |
| [`basics/16_popcount`](../src/basics/16_popcount) | 16 · 人口计数 popcount |
| [`basics/17_tff`](../src/basics/17_tff) | 17 · T 触发器 tff |
| [`basics/18_jkff`](../src/basics/18_jkff) | 18 · JK 触发器 jkff |
| [`basics/19_ring_counter`](../src/basics/19_ring_counter) | 19 · 环形计数器 ring_counter |
| [`basics/20_johnson_counter`](../src/basics/20_johnson_counter) | 20 · 约翰逊计数器 johnson_counter |
| [`basics/21_updown_counter`](../src/basics/21_updown_counter) | 21 · 可逆计数器 updown_counter |
| [`basics/22_bcd_counter`](../src/basics/22_bcd_counter) | 22 · BCD 计数器 bcd_counter |
| [`basics/23_lfsr`](../src/basics/23_lfsr) | 23 · 线性反馈移位寄存器 lfsr |
| [`basics/24_shift_register`](../src/basics/24_shift_register) | 24 · 通用移位寄存器 shift_register |

## 进阶 intermediate（30 个）

| 案例 | 说明 |
|------|------|
| [`intermediate/01_fsm`](../src/intermediate/01_fsm) | 01 · 有限状态机（FSM）—— 交通灯 |
| [`intermediate/02_uart`](../src/intermediate/02_uart) | 02 · UART 收发器（含回环测试） |
| [`intermediate/03_fifo`](../src/intermediate/03_fifo) | 03 · 同步 FIFO |
| [`intermediate/04_debounce`](../src/intermediate/04_debounce) | 04 · 按键消抖 + 边沿检测 |
| [`intermediate/05_seven_seg`](../src/intermediate/05_seven_seg) | 05 · 数码管显示 —— 二进制转 BCD + 扫描复用 |
| [`intermediate/06_ram`](../src/intermediate/06_ram) | 06 · 片上 RAM（Block RAM 推断） |
| [`intermediate/07_stopwatch`](../src/intermediate/07_stopwatch) | 07 · 秒表 stopwatch |
| [`intermediate/08_one_shot`](../src/intermediate/08_one_shot) | 08 · 单稳态触发器 one_shot |
| [`intermediate/09_edge_detector`](../src/intermediate/09_edge_detector) | 09 · 边沿检测 edge_detector |
| [`intermediate/10_clock_enable`](../src/intermediate/10_clock_enable) | 10 · 时钟使能发生器 clock_enable |
| [`intermediate/11_stack_lifo`](../src/intermediate/11_stack_lifo) | 11 · 栈 stack_lifo |
| [`intermediate/12_async_fifo`](../src/intermediate/12_async_fifo) | 12 · 异步 FIFO async_fifo |
| [`intermediate/13_dual_port_ram`](../src/intermediate/13_dual_port_ram) | 13 · 双口 RAM dual_port_ram |
| [`intermediate/14_sine_rom`](../src/intermediate/14_sine_rom) | 14 · 正弦查找表 sine_rom |
| [`intermediate/15_uart_loopback`](../src/intermediate/15_uart_loopback) | 15 · UART 自环 uart_loopback |
| [`intermediate/16_spi_slave`](../src/intermediate/16_spi_slave) | 16 · SPI 从机 spi_slave |
| [`intermediate/17_seven_seg_mux4`](../src/intermediate/17_seven_seg_mux4) | 17 · 4 位数码管动态扫描 seven_seg_mux4 |
| [`intermediate/18_keypad_scanner`](../src/intermediate/18_keypad_scanner) | 18 · 矩阵键盘扫描 keypad_scanner |
| [`intermediate/19_prog_timer`](../src/intermediate/19_prog_timer) | 19 · 可编程定时器 prog_timer |
| [`intermediate/20_watchdog`](../src/intermediate/20_watchdog) | 20 · 看门狗 watchdog |
| [`intermediate/21_freq_counter`](../src/intermediate/21_freq_counter) | 21 · 频率计 freq_counter |
| [`intermediate/22_duty_measure`](../src/intermediate/22_duty_measure) | 22 · 占空比测量 duty_measure |
| [`intermediate/23_manchester_enc`](../src/intermediate/23_manchester_enc) | 23 · 曼彻斯特编码器 manchester_enc |
| [`intermediate/24_manchester_dec`](../src/intermediate/24_manchester_dec) | 24 · 曼彻斯特解码器 manchester_dec |
| [`intermediate/25_crc8`](../src/intermediate/25_crc8) | 25 · CRC-8 crc8 |
| [`intermediate/26_crc16`](../src/intermediate/26_crc16) | 26 · CRC-16 crc16 |
| [`intermediate/27_hamming74`](../src/intermediate/27_hamming74) | 27 · 汉明码 (7,4) hamming74 |
| [`intermediate/28_ps2_rx`](../src/intermediate/28_ps2_rx) | 28 · PS/2 接收器 ps2_rx |
| [`intermediate/29_pwm_capture`](../src/intermediate/29_pwm_capture) | 29 · 输入捕获 pwm_capture |
| [`intermediate/30_debounce_multi`](../src/intermediate/30_debounce_multi) | 30 · 多路按键消抖 debounce_multi |

## 高级 advanced（25 个）

| 案例 | 说明 |
|------|------|
| [`advanced/01_pwm_led`](../src/advanced/01_pwm_led) | 01 · PWM 脉宽调制（LED 呼吸灯 / 电机调速） |
| [`advanced/02_spi_master`](../src/advanced/02_spi_master) | 02 · SPI 主机（Mode 0） |
| [`advanced/03_vga`](../src/advanced/03_vga) | 03 · VGA 时序产生器（640×480@60Hz） |
| [`advanced/04_fir`](../src/advanced/04_fir) | 04 · 移动平均 / FIR 滤波器 |
| [`advanced/05_dds`](../src/advanced/05_dds) | 05 · DDS / NCO dds |
| [`advanced/06_cordic_sincos`](../src/advanced/06_cordic_sincos) | 06 · CORDIC sin/cos cordic_sincos |
| [`advanced/07_seq_divider`](../src/advanced/07_seq_divider) | 07 · 序列除法器 seq_divider |
| [`advanced/08_seq_sqrt`](../src/advanced/08_seq_sqrt) | 08 · 整数平方根 seq_sqrt |
| [`advanced/09_booth_mul`](../src/advanced/09_booth_mul) | 09 · Booth 有符号乘法器 booth_mul |
| [`advanced/10_mac`](../src/advanced/10_mac) | 10 · 乘累加器 mac |
| [`advanced/11_sigma_delta_dac`](../src/advanced/11_sigma_delta_dac) | 11 · Sigma-Delta DAC sigma_delta_dac |
| [`advanced/12_pwm_multi`](../src/advanced/12_pwm_multi) | 12 · 多通道 PWM pwm_multi |
| [`advanced/13_servo_pwm`](../src/advanced/13_servo_pwm) | 13 · 舵机 PWM servo_pwm |
| [`advanced/14_stepper_drive`](../src/advanced/14_stepper_drive) | 14 · 步进电机驱动 stepper_drive |
| [`advanced/15_uart_tx_fifo`](../src/advanced/15_uart_tx_fifo) | 15 · 带 FIFO 的 UART 发送 uart_tx_fifo |
| [`advanced/16_skid_buffer`](../src/advanced/16_skid_buffer) | 16 · Skid Buffer skid_buffer |
| [`advanced/17_rr_arbiter`](../src/advanced/17_rr_arbiter) | 17 · 轮询仲裁器 rr_arbiter |
| [`advanced/18_prio_arbiter`](../src/advanced/18_prio_arbiter) | 18 · 固定优先级仲裁器 prio_arbiter |
| [`advanced/19_crossbar`](../src/advanced/19_crossbar) | 19 · 交叉开关 crossbar |
| [`advanced/20_apb_regfile`](../src/advanced/20_apb_regfile) | 20 · APB 寄存器堆 apb_regfile |
| [`advanced/21_spi_master_modes`](../src/advanced/21_spi_master_modes) | 21 · 可配置 SPI 主机 spi_master_modes |
| [`advanced/22_i2c_master_write`](../src/advanced/22_i2c_master_write) | 22 · I2C 主机(多字节写) i2c_master_write |
| [`advanced/23_vga_pattern`](../src/advanced/23_vga_pattern) | 23 · VGA 彩条发生器 vga_pattern |
| [`advanced/24_fifo_progfull`](../src/advanced/24_fifo_progfull) | 24 · 可编程满标志 FIFO fifo_progfull |
| [`advanced/25_pulse_sync`](../src/advanced/25_pulse_sync) | 25 · 跨时钟域脉冲同步器 pulse_sync |

## 综合 projects（21 个）

| 案例 | 说明 |
|------|------|
| [`projects/01_encoder_pwm_loop`](../src/projects/01_encoder_pwm_loop) | 组合项目 01 · 闭环电机调速（编码器 + 测速 + P 控制 + PWM） |
| [`projects/02_i2c_sensor_uart`](../src/projects/02_i2c_sensor_uart) | 组合项目 02 · I2C 读传感器 + UART 上报 |
| [`projects/03_button_counter_seg`](../src/projects/03_button_counter_seg) | 组合项目 03 · 按键计数数码管（去抖 + 计数 + BCD + 7段译码） |
| [`projects/04_uart_echo`](../src/projects/04_uart_echo) | 04 · UART 回显器 uart_echo |
| [`projects/05_button_uart_report`](../src/projects/05_button_uart_report) | 05 · 按键计数串口上报 button_uart_report |
| [`projects/06_freq_meter_seg`](../src/projects/06_freq_meter_seg) | 06 · 频率计+数码管 freq_meter_seg |
| [`projects/07_stopwatch_seg`](../src/projects/07_stopwatch_seg) | 07 · 秒表+数码管 stopwatch_seg |
| [`projects/08_pwm_rgb`](../src/projects/08_pwm_rgb) | 08 · RGB PWM 调光 pwm_rgb |
| [`projects/09_servo_sweep`](../src/projects/09_servo_sweep) | 09 · 舵机自动扫摆 servo_sweep |
| [`projects/10_stepper_position`](../src/projects/10_stepper_position) | 10 · 步进电机定位 stepper_position |
| [`projects/11_keypad_seg`](../src/projects/11_keypad_seg) | 11 · 矩阵键盘+数码管 keypad_seg |
| [`projects/12_sram_blockcopy`](../src/projects/12_sram_blockcopy) | 12 · 片上 RAM 自检 sram_blockcopy |
| [`projects/13_vga_box`](../src/projects/13_vga_box) | 13 · VGA 移动方块 vga_box |
| [`projects/14_manchester_link`](../src/projects/14_manchester_link) | 14 · 曼彻斯特编解码链路 manchester_link |
| [`projects/15_uart_crc_frame`](../src/projects/15_uart_crc_frame) | 15 · 带 CRC 的 UART 帧 uart_crc_frame |
| [`projects/16_i2c_alarm`](../src/projects/16_i2c_alarm) | 16 · I2C 传感器超阈报警 i2c_alarm |
| [`projects/17_spi_link`](../src/projects/17_spi_link) | 17 · SPI 主从全双工链路 spi_link |
| [`projects/18_adc_movavg_uart`](../src/projects/18_adc_movavg_uart) | 18 · 采样滤波串口上报 adc_movavg_uart |
| [`projects/19_dds_uart_ctrl`](../src/projects/19_dds_uart_ctrl) | 19 · 串口控制 DDS 频率 dds_uart_ctrl |
| [`projects/20_traffic_pedestrian`](../src/projects/20_traffic_pedestrian) | 20 · 带行人请求的红绿灯 traffic_pedestrian |
| [`projects/21_alu_datapath`](../src/projects/21_alu_datapath) | 21 · 微指令 ALU 数据通路 alu_datapath（收官） |
