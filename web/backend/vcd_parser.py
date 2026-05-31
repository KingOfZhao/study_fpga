"""极简 VCD 解析器：把 iverilog/vvp 产生的 .vcd 文件解析成前端易渲染的 JSON。

输出结构：
{
  "timescale": "1ns",
  "end_time": 266,
  "signals": [
     {"id": "!", "name": "hello_tb.clk", "width": 1},
     {"id": "\"", "name": "hello_tb.count", "width": 4},
     ...
  ],
  "changes": {
     "!": [[0, "0"], [5, "1"], ...],     # [time, value]
     "\"": [[0, "0000"], [10, "0001"], ...]
  }
}

value 对单 bit 是 "0"/"1"/"x"/"z"；对总线是去掉前导 b 的二进制字符串（已按宽度左侧补 0）。
"""
from __future__ import annotations

import re
from typing import Dict, List


def parse_vcd(text: str) -> dict:
    timescale = "1ns"
    # id -> {name, width}
    sig_meta: Dict[str, dict] = {}
    scope_stack: List[str] = []
    changes: Dict[str, List[list]] = {}
    order: List[str] = []

    lines = text.splitlines()
    i = 0
    in_defs = True
    cur_time = 0
    end_time = 0

    var_re = re.compile(r"\$var\s+\w+\s+(\d+)\s+(\S+)\s+(\S+?)(?:\s+\[[^\]]*\])?\s+\$end")
    ts_re = re.compile(r"\$timescale\s+(.+?)\s+\$end")

    # header / definitions 可能跨行，简单按 token 处理较稳妥
    joined = "\n".join(lines)

    # timescale 可能是 "$timescale 1ns $end" 或分行
    m = ts_re.search(joined.replace("\n", " "))
    if m:
        timescale = m.group(1).strip()

    while i < len(lines):
        line = lines[i].strip()
        i += 1
        if not line:
            continue

        if in_defs:
            if line.startswith("$scope"):
                parts = line.split()
                if len(parts) >= 3:
                    scope_stack.append(parts[2])
                continue
            if line.startswith("$upscope"):
                if scope_stack:
                    scope_stack.pop()
                continue
            if line.startswith("$var"):
                vm = var_re.search(line)
                if vm:
                    width = int(vm.group(1))
                    sid = vm.group(2)
                    sname = vm.group(3)
                    full = ".".join(scope_stack + [sname]) if scope_stack else sname
                    if sid not in sig_meta:
                        sig_meta[sid] = {"id": sid, "name": full, "width": width}
                        changes[sid] = []
                        order.append(sid)
                continue
            if line.startswith("$enddefinitions"):
                in_defs = False
                continue
            # 其它 $timescale/$date/$version 行忽略
            continue

        # value change 区
        if line[0] == "#":
            try:
                cur_time = int(line[1:])
                end_time = max(end_time, cur_time)
            except ValueError:
                pass
            continue

        c = line[0]
        if c in "01xXzZ":
            # 标量：值紧跟 id，如 "0!"
            val = c.lower()
            sid = line[1:].strip()
            if sid in changes:
                changes[sid].append([cur_time, val])
        elif c in "bB":
            # 向量：bVALUE id
            parts = line[1:].split()
            if len(parts) >= 2:
                raw = parts[0]
                sid = parts[1]
                if sid in sig_meta:
                    w = sig_meta[sid]["width"]
                    val = raw.lower()
                    if all(ch in "01" for ch in val):
                        val = val.zfill(w)
                    changes[sid].append([cur_time, val])
        elif c in "rR":
            # 实数，简单忽略/记录字符串
            parts = line[1:].split()
            if len(parts) >= 2 and parts[1] in changes:
                changes[parts[1]].append([cur_time, parts[0]])
        # 其它忽略

    signals = [sig_meta[sid] for sid in order]
    return {
        "timescale": timescale,
        "end_time": end_time,
        "signals": signals,
        "changes": changes,
    }
