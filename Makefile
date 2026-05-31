# 顶层 Makefile —— 一键管理所有案例
#
#   make test     编译并运行所有案例的自校验仿真（CI 也用它）
#   make lint     对所有设计文件做 verilator 静态检查
#   make list     列出全部案例目录
#   make clean    清理所有生成文件

.PHONY: test lint list clean

test:
	@bash scripts/run_all.sh

lint:
	@bash scripts/lint_all.sh

list:
	@find src -type f -name Makefile -printf '%h\n' | sort

clean:
	@find src -type f -name Makefile -printf '%h\n' | while read -r d; do \
		$(MAKE) -C "$$d" clean >/dev/null 2>&1 || true; \
	done
	@echo "已清理所有生成文件"
