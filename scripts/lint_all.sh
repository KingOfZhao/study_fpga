#!/usr/bin/env bash
# 对所有案例的设计文件做 verilator 静态检查（lint）。
# 警告不计为失败，仅用于学习时发现潜在问题。
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mapfile -t DIRS < <(find src -type f -name Makefile -printf '%h\n' | sort)

for d in "${DIRS[@]}"; do
    echo ">>> lint $d"
    make -C "$d" lint || true
    echo
done
