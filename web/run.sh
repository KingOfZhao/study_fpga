#!/usr/bin/env bash
# 一键启动 FPGA 学习平台 Web（后端仿真 + 前端页面）
# macOS / Linux 通用。需先安装 iverilog：
#   macOS:  brew install icarus-verilog        （可选：brew install yosys）
#   Ubuntu: sudo apt-get install iverilog       （可选：sudo apt-get install yosys）
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/backend"

# Python venv
if [ ! -d ".venv" ]; then
  echo "[setup] 创建 Python 虚拟环境 .venv …"
  python3 -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate

echo "[setup] 安装依赖 …"
pip install -q -r requirements.txt

# 工具检测
if ! command -v iverilog >/dev/null 2>&1; then
  echo "⚠️  未检测到 iverilog。macOS 请运行: brew install icarus-verilog"
fi

PORT="${PORT:-8000}"
echo ""
echo "============================================================"
echo "  FPGA 学习平台已启动:  http://localhost:${PORT}"
echo "  左侧选案例 → 改代码 → 「▶ 运行仿真」看波形"
echo "  组合逻辑案例可点「🎛 交互式芯片仿真」拨动输入看输出"
echo "  Ctrl+C 退出"
echo "============================================================"
exec uvicorn app:app --host 0.0.0.0 --port "${PORT}"
