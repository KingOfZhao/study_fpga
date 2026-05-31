"""FPGA 学习平台 Web 后端（方案 A：真实 iverilog/vvp 仿真）。

职责：
1. /api/examples            列出仓库 src/ 下的全部案例及其源码
2. /api/simulate            接收一组 Verilog 文件，编译+运行，返回解析后的 VCD 波形
3. /api/synth               用 yosys 综合，返回门级 JSON 网表（方案 B 的数据源）
4. /                        托管前端静态页面

依赖外部工具：iverilog、vvp（必需）；yosys（/api/synth 可选）。
macOS 安装：brew install icarus-verilog yosys
"""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import List, Optional

from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from vcd_parser import parse_vcd

REPO_ROOT = Path(__file__).resolve().parents[2]
SRC_DIR = REPO_ROOT / "src"
FRONTEND_DIR = REPO_ROOT / "web" / "frontend"

SIM_TIMEOUT = 15  # 秒，防止死循环 testbench 卡死后端

app = FastAPI(title="FPGA 学习平台", version="1.0")


# ----------------------------- 数据模型 -----------------------------
class SrcFile(BaseModel):
    name: str
    content: str


class SimulateRequest(BaseModel):
    files: List[SrcFile]
    top: Optional[str] = None  # 预留：指定顶层 testbench 模块


# ----------------------------- 工具函数 -----------------------------
def _tool_exists(name: str) -> bool:
    return shutil.which(name) is not None


def _discover_examples() -> list:
    """遍历 src/<category>/<NN_name>/，返回案例列表（含源码）。"""
    examples = []
    if not SRC_DIR.is_dir():
        return examples
    for category_dir in sorted(SRC_DIR.iterdir()):
        if not category_dir.is_dir():
            continue
        for ex_dir in sorted(category_dir.iterdir()):
            if not ex_dir.is_dir():
                continue
            v_files = sorted(ex_dir.glob("*.v"))
            if not v_files:
                continue
            files = []
            tb_name = None
            for vf in v_files:
                text = vf.read_text(encoding="utf-8", errors="replace")
                files.append({"name": vf.name, "content": text})
                if vf.name.endswith("_tb.v") or "tb" in vf.name:
                    tb_name = vf.name
            readme = ex_dir / "README.md"
            examples.append({
                "id": f"{category_dir.name}/{ex_dir.name}",
                "category": category_dir.name,
                "name": ex_dir.name,
                "files": files,
                "tb": tb_name,
                "readme": readme.read_text(encoding="utf-8", errors="replace") if readme.exists() else "",
            })
    return examples


def _safe_name(name: str) -> str:
    """只允许简单文件名，避免路径穿越。"""
    base = os.path.basename(name)
    if not re.fullmatch(r"[A-Za-z0-9_.\-]+\.v", base):
        raise ValueError(f"非法文件名: {name}")
    return base


def _run(cmd: list, cwd: str, timeout: int) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout
    )


# ----------------------------- API -----------------------------
@app.get("/api/health")
def health():
    return {
        "ok": True,
        "iverilog": _tool_exists("iverilog"),
        "vvp": _tool_exists("vvp"),
        "yosys": _tool_exists("yosys"),
    }


@app.get("/api/examples")
def examples():
    return {"examples": _discover_examples()}


@app.post("/api/simulate")
def simulate(req: SimulateRequest):
    if not _tool_exists("iverilog") or not _tool_exists("vvp"):
        return {
            "ok": False,
            "stage": "env",
            "log": "未找到 iverilog/vvp。macOS 请先运行：brew install icarus-verilog",
        }
    if not req.files:
        return {"ok": False, "stage": "input", "log": "没有提供任何 .v 文件"}

    with tempfile.TemporaryDirectory(prefix="fpga_sim_") as tmp:
        names = []
        try:
            for f in req.files:
                safe = _safe_name(f.name)
                (Path(tmp) / safe).write_text(f.content, encoding="utf-8")
                names.append(safe)
        except ValueError as e:
            return {"ok": False, "stage": "input", "log": str(e)}

        # 1) 编译
        try:
            comp = _run(["iverilog", "-g2012", "-Wall", "-o", "sim.vvp", *names], tmp, SIM_TIMEOUT)
        except subprocess.TimeoutExpired:
            return {"ok": False, "stage": "compile", "log": "编译超时"}
        comp_log = (comp.stdout or "") + (comp.stderr or "")
        if comp.returncode != 0:
            return {"ok": False, "stage": "compile", "log": comp_log or "编译失败"}

        # 2) 运行
        try:
            run = _run(["vvp", "sim.vvp"], tmp, SIM_TIMEOUT)
        except subprocess.TimeoutExpired:
            return {"ok": False, "stage": "run", "log": comp_log + "\n[运行超时：检查 testbench 是否有 $finish]"}
        run_log = (run.stdout or "") + (run.stderr or "")

        full_log = (comp_log + "\n" + run_log).strip()
        passed = "[PASS]" in run_log
        failed = "[FAIL]" in run_log or "$fatal" in run_log

        # 3) 读取 VCD（取目录下最新的 .vcd）
        vcds = sorted(Path(tmp).glob("*.vcd"), key=lambda p: p.stat().st_mtime, reverse=True)
        waveform = None
        if vcds:
            try:
                waveform = parse_vcd(vcds[0].read_text(encoding="utf-8", errors="replace"))
            except Exception as e:  # noqa: BLE001
                waveform = None
                full_log += f"\n[VCD 解析失败: {e}]"

        return {
            "ok": True,
            "stage": "done",
            "passed": passed,
            "failed": failed,
            "log": full_log,
            "waveform": waveform,
            "has_vcd": waveform is not None,
        }


@app.post("/api/synth")
def synth(req: SimulateRequest):
    """方案 B：用 yosys 综合为门级 JSON 网表（前端可做交互式门级仿真/示意）。"""
    if not _tool_exists("yosys"):
        return {"ok": False, "log": "未找到 yosys。macOS 请运行：brew install yosys"}
    design_files = [f for f in req.files if not (f.name.endswith("_tb.v") or "_tb" in f.name)]
    if not design_files:
        return {"ok": False, "log": "没有可综合的设计文件（已排除 *_tb.v）"}

    with tempfile.TemporaryDirectory(prefix="fpga_synth_") as tmp:
        names = []
        try:
            for f in design_files:
                safe = _safe_name(f.name)
                (Path(tmp) / safe).write_text(f.content, encoding="utf-8")
                names.append(safe)
        except ValueError as e:
            return {"ok": False, "log": str(e)}

        read_cmds = " ".join(f"read_verilog -sv {n};" for n in names)
        script = f"{read_cmds} proc; opt; fsm; opt; memory; opt; write_json netlist.json"
        try:
            res = _run(["yosys", "-q", "-p", script], tmp, SIM_TIMEOUT)
        except subprocess.TimeoutExpired:
            return {"ok": False, "log": "yosys 综合超时"}
        log = (res.stdout or "") + (res.stderr or "")
        netlist_path = Path(tmp) / "netlist.json"
        if res.returncode != 0 or not netlist_path.exists():
            return {"ok": False, "log": log or "yosys 综合失败"}
        import json
        try:
            netlist = json.loads(netlist_path.read_text(encoding="utf-8"))
        except Exception as e:  # noqa: BLE001
            return {"ok": False, "log": f"网表解析失败: {e}"}
        return {"ok": True, "log": log, "netlist": netlist}


# ----------------------------- 静态前端 -----------------------------
if FRONTEND_DIR.is_dir():
    app.mount("/static", StaticFiles(directory=str(FRONTEND_DIR)), name="static")

    @app.get("/")
    def index():
        return FileResponse(str(FRONTEND_DIR / "index.html"))
