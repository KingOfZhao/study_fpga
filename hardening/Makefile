# 上板加固模块自检（独立于 src/ 的 100 个案例，不计入 make test 汇总）
TOP_TB := hardening_tb
SRCS   := synchronizer.v reset_sync.v i2c_iobuf_top.v hardening_tb.v

all: test
test:
	iverilog -g2012 -Wall -o $(TOP_TB).vvp $(SRCS)
	vvp $(TOP_TB).vvp
lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-MULTITOP synchronizer.v reset_sync.v i2c_iobuf_top.v
clean:
	rm -f *.vvp *.vcd
.PHONY: all test lint clean
