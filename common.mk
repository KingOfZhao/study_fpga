# common.mk — 所有案例共用的仿真/检查规则
#
# 用法：在每个案例目录的 Makefile 里（可选地）覆盖变量后 include 本文件：
#   TOP   ?= <testbench 顶层模块名>   # 默认取目录里 *_tb.v 的文件名
#   SRCS  ?= <verilog 源文件列表>     # 默认取目录里所有 *.v
#   include ../../common.mk
#
# 提供的目标：
#   make / make sim   编译并运行仿真（生成 .vcd 波形）
#   make wave         用 GTKWave 打开波形
#   make lint         用 verilator 做静态检查（仅设计文件）
#   make clean        清理生成物

IVERILOG  ?= iverilog
VVP       ?= vvp
VERILATOR ?= verilator
GTKWAVE   ?= gtkwave

# 自动探测：所有 .v 为源文件；*_tb.v 为 testbench；顶层模块名取第一个 testbench 的文件名
SRCS   ?= $(wildcard *.v)
TB_SRC ?= $(wildcard *_tb.v)
TOP    ?= $(basename $(notdir $(firstword $(TB_SRC))))

VVP_OUT := $(TOP).vvp
VCD_OUT := $(TOP).vcd

.PHONY: sim wave lint clean
sim: $(VCD_OUT)

$(VVP_OUT): $(SRCS)
	$(IVERILOG) -g2012 -Wall -o $@ $(SRCS)

$(VCD_OUT): $(VVP_OUT)
	$(VVP) $<

# 打开波形（后台启动 GTKWave）
wave: $(VCD_OUT)
	$(GTKWAVE) $(VCD_OUT) >/dev/null 2>&1 &

# 仅对设计文件做静态检查（排除 testbench）
DESIGN_SRCS := $(filter-out $(TB_SRC),$(SRCS))
lint:
	$(VERILATOR) --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSED -Wno-MULTITOP $(DESIGN_SRCS)

clean:
	rm -f *.vvp *.vcd *.fst
