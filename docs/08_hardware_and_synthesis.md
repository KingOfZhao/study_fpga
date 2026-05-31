# 上板与工程化注意事项（仿真通过 ≠ 能上板）

本仓库 100 个案例都以**功能仿真**为目标，`make test` 全绿只代表逻辑功能正确。
真正烧到 FPGA 还要处理一批仿真**不会暴露**的工程问题。本文把审计出的要点逐条列清，
并在 [`../hardening/`](../hardening) 提供了**已验证可用的加固模块**（同步器 / 复位同步器 / I2C 三态封装）。

```bash
cd hardening && make        # 运行加固模块自检，应打印 [PASS]
```

---

## 1. 异步输入必须先过同步器（亚稳态）

凡是与 FPGA 时钟**异步**的单 bit 输入，直接采样可能在时钟沿附近违反建立/保持时间，
进入亚稳态并把不确定值传播进逻辑，导致偶发误动作。涉及本仓库：

| 信号 | 出现案例 |
|------|----------|
| `btn_in` | `intermediate/04_debounce`、`30_debounce_multi`、所有按键案例 |
| `enc_a/enc_b` | `projects/01_encoder_pwm_loop` 的 `quad_decoder` |
| UART `rx`/PS2 `ps2_clk/ps2_data` | `intermediate/02_uart`、`28_ps2_rx` |
| I2C `sda_i` | `advanced/22_i2c_master_write`、`projects/16_i2c_alarm` |

**修法**：上板前在输入第一级加两级触发器同步器。直接用 [`hardening/synchronizer.v`](../hardening/synchronizer.v)：

```verilog
synchronizer #(.STAGES(2)) u_sync_btn (
    .clk(clk), .rst_n(rst_n), .async_in(btn_pin), .sync_out(btn_sync));
// 之后把 btn_sync 接到原来的 debounce 输入
```

> 多 bit 异步总线不能逐 bit 各过同步器（会错位），要用 FIFO / 握手 / 格雷码（见 `intermediate/12_async_fifo`）。

## 2. 复位策略：异步置位 / 同步释放

本仓库统一用 `always @(posedge clk or negedge rst_n)` 的异步复位。上板推荐 **reset synchronizer**：
复位**异步生效**（立即），但**同步释放**（与时钟对齐），否则释放瞬间各触发器脱离复位的时刻不同，可能进非法态。

用 [`hardening/reset_sync.v`](../hardening/reset_sync.v) 产生全局 `srst_n` 再分发：

```verilog
reset_sync u_rs (.clk(clk), .arst_n(ext_rst_n_pin), .srst_n(rst_n));
```

外部复位按钮本身也要去抖（见 `intermediate/04_debounce`）。

## 3. I2C / 1-Wire 等开漏总线需要真正的三态 inout

仿真里我们用 `sda_oe`（拉低使能）+ `sda_i`（回读）两根线，**综合到板子上**必须是 `inout` 引脚 +
开漏三态 + 外部上拉电阻（典型 4.7kΩ 到 VCC）。封装见 [`hardening/i2c_iobuf_top.v`](../hardening/i2c_iobuf_top.v)：

```verilog
assign sda   = sda_oe ? 1'b0 : 1'bz;   // 只拉低，高电平靠外部上拉
assign sda_i = sda;                     // 回读总线真实电平（含从机 ACK）
```

约束文件里这两个引脚要设成支持双向 + 适当上拉/驱动能力。

## 4. 时钟与跨时钟域（CDC）

- **像素/外设时钟**：`advanced/03_vga` 的 25.175MHz 像素时钟仿真里靠分频近似，上板要用 **PLL/MMCM** 时钟 IP 生成，并写时钟约束（`create_clock`）。
- **跨时钟域**：单 bit 用脉冲同步（`advanced/25_pulse_sync`，toggle+2FF）；多 bit/数据流用异步 FIFO（`intermediate/12_async_fifo`，格雷码指针）。绝不要让组合逻辑跨域裸连。
- **不要在逻辑里用门控时钟**做使能，改用**时钟使能**（`intermediate/10_clock_enable`）。

## 5. 引脚约束 / 时序约束

- 每个上板外设引脚都要在约束文件里指定**位置 + 电平标准**（Xilinx `.xdc` / Lattice `.pcf`，见 [`../constraints/`](../constraints)）。
- 主时钟要 `create_clock`；异步/伪路径用 `set_false_path` / `set_max_delay` 标注（同步器两级之间通常设 false path）。
- 编译后**看时序报告**确认 setup/hold 都 met，再下载。

## 6. 烧录与在线调试

- **烧录**：Xilinx 用 Vivado Hardware Manager（JTAG）；Lattice 用 `iceprog`（开源 iCE40 流程：`yosys` → `nextpnr` → `icepack` → `iceprog`）。
- **在线抓信号**：Xilinx **ILA**（Integrated Logic Analyzer）/ Intel **SignalTap**，相当于把逻辑分析仪做进 FPGA；可参考 `intermediate/06_ram`（把信号采进 BRAM）思路自建简易抓取。
- **串口打印**：最轻量的调试是把内部状态经 UART 上报（见 `projects/05_button_uart_report`）。

## 7. 资源与时序权衡（上板前自查）

| 关注点 | 说明 | 相关案例 |
|--------|------|----------|
| LUT/FF/BRAM/DSP 占用 | 综合后看 utilization 报告，避免超资源 | 乘法器映射到 DSP：`advanced/09_booth_mul`、`10_mac` |
| 关键路径 | 长组合链拆流水线提主频 | 串行算法可改迭代/流水：`advanced/07_seq_divider`、`08_seq_sqrt` |
| 初值 | FPGA 上电 BRAM/FF 可有初值，ASIC 思路不同 | `intermediate/14_sine_rom` ROM 初始化 |
| 复位扇出 | 全局复位扇出大，必要时用同步复位减负载 | 见本文 §2 |

---

## 加固模块清单（[`../hardening/`](../hardening)，已自检 [PASS]）

| 模块 | 作用 |
|------|------|
| [`synchronizer.v`](../hardening/synchronizer.v) | 参数化两级（可配级数）同步器，异步单 bit 入域 |
| [`reset_sync.v`](../hardening/reset_sync.v) | 异步置位/同步释放复位同步器 |
| [`i2c_iobuf_top.v`](../hardening/i2c_iobuf_top.v) | 开漏 inout 三态封装示例（配外部上拉） |

> 这些模块独立于 `src/` 的 100 个学习案例，**不改动也不影响**它们的功能仿真；
> 需要上板时按上文把它们接到对应输入/复位/总线即可。
