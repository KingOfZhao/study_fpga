# FPGA 学习平台 · 可视化 Web（在线改代码 + 实时波形 + 交互式芯片仿真）

在浏览器里编辑 Verilog → 后端用真实的 `iverilog`/`vvp` 编译运行 → 前端用 **Canvas** 画出波形；
组合逻辑还能在「交互面板」里**拨动输入开关、实时看输出 LED**，直观体验“操作一块芯片”。

> 这是对仓库 `src/` 下 9 个案例的可视化封装：网页左侧直接载入这些案例的源码，改完即可仿真。

---

## 1. 架构

```
浏览器 (前端, 纯静态)                后端 (FastAPI, Python)              系统工具
┌─────────────────────┐  POST       ┌──────────────────────┐  subprocess ┌───────────┐
│ CodeMirror 代码编辑器 │ ──/api/──▶ │ /api/simulate        │ ─────────▶ │ iverilog  │
│ Canvas 波形渲染      │ ◀─JSON───  │   写临时文件→编译→运行 │           │ vvp       │
│ 交互式开关/LED 面板   │            │   解析 VCD → JSON     │           │ (yosys)   │
└─────────────────────┘            └──────────────────────┘            └───────────┘
```

- `backend/app.py`：FastAPI 服务。`/api/examples` 列出案例源码；`/api/simulate` 编译+运行+解析 VCD；`/api/synth` 用 yosys 导出门级网表；并托管前端静态页。
- `backend/vcd_parser.py`：把 `.vcd` 解析成 `{signals, changes}` 供前端渲染。
- `frontend/`：`index.html` + `style.css` + `app.js`（主逻辑）+ `waveform.js`（Canvas 波形）。

---

## 2. 环境部署

### macOS（推荐，含你的使用场景）
```bash
# 1) 安装仿真工具（Homebrew）
brew install icarus-verilog       # 提供 iverilog / vvp（必需）
brew install yosys                # 可选：用于 /api/synth 导出门级网表
# 如未装 Homebrew：/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2) 需要 Python 3.9+（macOS 自带 python3，或 brew install python）
python3 --version
```

### Ubuntu / WSL
```bash
sudo apt-get update
sudo apt-get install -y iverilog python3-venv   # 可选: sudo apt-get install -y yosys
```

---

## 3. 一键运行

```bash
cd web
./run.sh
```
脚本会自动：创建 `backend/.venv` → 安装 Python 依赖 → 启动服务。
看到下面这行后，用浏览器打开 **http://localhost:8000** ：
```
FPGA 学习平台已启动:  http://localhost:8000
```
换端口：`PORT=9000 ./run.sh`

> 手动启动（等价）：
> ```bash
> cd web/backend
> python3 -m venv .venv && source .venv/bin/activate
> pip install -r requirements.txt
> uvicorn app:app --reload --port 8000
> ```

---

## 4. 使用方法

1. **选案例**：左侧「案例库」按 基础/进阶/高级 分组，点任意案例载入源码（设计文件 + testbench）。
2. **改代码**：中间编辑器支持多文件标签页（如 `pwm.v` / `pwm_tb.v`），Verilog 语法高亮。
3. **运行仿真 (A)**：点右上「▶ 运行仿真」。
   - 顶部状态显示 `仿真通过 [PASS]` / `有断言 FAIL` / `编译错误`。
   - 右侧「波形」标签用 Canvas 画出所有信号：单 bit 是高低电平方波，总线显示十六进制数值；用 `＋ / － / 适应` 缩放，拖动横向滚动。
   - 「仿真日志」标签显示 iverilog 编译信息与 `$display` 输出。
4. **交互式芯片仿真 (B)**：对**组合逻辑**案例（如 `02_combinational` 全加器、`03_mux_decoder`），点「🎛 交互式芯片仿真」：
   - 输入端口渲染成**开关**（单 bit）或数字输入框（总线）；
   - 拨动后前端生成一个临时 testbench 调后端求值，**输出 LED / 数值实时更新**；
   - 例：全加器 `a=1, b=1, cin=0` → `sum=0, cout=1`（即 1+1=二进制 10）。
   - 时序逻辑（含 `clk`）不走交互开关，请用「运行仿真」看波形。

---

## 5. 调试方法

| 现象 | 排查 |
|---|---|
| 状态显示「编译错误」 | 看「仿真日志」标签里的 iverilog 报错（行号、语法）。 |
| 仿真「运行超时」 | testbench 缺 `$finish` 或存在死循环；后端单次仿真上限 15s。 |
| 波形为空 | testbench 里需有 `$dumpfile("x.vcd"); $dumpvars(0, tb);`，否则不产生 VCD。 |
| 交互面板提示“含时钟” | 该模块是时序逻辑，改用「运行仿真」看波形。 |
| 环境栏显示 `iverilog ✗ 缺失` | 未安装 Icarus Verilog：`brew install icarus-verilog`。 |
| 端口被占用 | 换端口：`PORT=9000 ./run.sh`。 |

后端日志直接打印在运行 `run.sh` 的终端；`uvicorn ... --reload` 可热重载便于改后端。

---

## 6. 芯片仿真操作方法（两种）

- **波形仿真（时序/组合都适用）**：改代码 → 运行仿真 → 看 Canvas 波形随时间变化。等价于本地 `iverilog + vvp + gtkwave`，结果完全一致。
- **交互式门级/真值表仿真（组合逻辑）**：拨动输入开关看输出，等价于把模块当成一块实物芯片来“按按钮、看灯”。
- **导出门级网表（进阶）**：`POST /api/synth`（需 yosys）返回 DigitalJS 兼容的 JSON 网表，可粘贴到 https://digitaljs.tilk.eu/ 在线查看并交互式仿真门级电路。
  ```bash
  curl -s -X POST http://localhost:8000/api/synth -H 'Content-Type: application/json' \
    -d '{"files":[{"name":"full_adder.v","content":"<你的 Verilog>"}]}'
  ```

---

## 7. 安全说明

`/api/simulate` 会在临时目录里**真实运行**你提交的 Verilog（带 15s 超时与文件名白名单）。
这是给本地学习用的工具，请勿把它暴露到公网上运行不受信任的代码。
