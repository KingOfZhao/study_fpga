#!/usr/bin/env bash
# 运行所有案例的自校验仿真，汇总 PASS/FAIL。
# 用法：bash scripts/run_all.sh   （或在仓库根目录执行 make test）
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# 发现所有包含 Makefile 的案例目录（按路径排序）
mapfile -t DIRS < <(find src -type f -name Makefile -printf '%h\n' | sort)

pass=0
fail=0
failed_list=()

for d in "${DIRS[@]}"; do
    echo "==================================================================="
    echo ">>> $d"
    echo "==================================================================="
    out="$(make -C "$d" clean >/dev/null 2>&1; make -C "$d" 2>&1)"
    echo "$out"
    if echo "$out" | grep -q "\[PASS\]" && ! echo "$out" | grep -q "\[FAIL\]"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failed_list+=("$d")
    fi
    echo
done

echo "==================================================================="
echo "汇总：通过 $pass 个，失败 $fail 个"
if [ "$fail" -ne 0 ]; then
    echo "失败的案例："
    for f in "${failed_list[@]}"; do echo "  - $f"; done
    exit 1
fi
echo "全部案例通过 ✔"
