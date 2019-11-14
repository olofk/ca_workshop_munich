CWD=$(shell pwd)

MODULE = test_wb_sevenseg
VERILOG_SOURCES = $(CWD)/../wb_sevenseg.v
TOPLEVEL = wb_sevenseg
COMPILE_ARGS = -DWAVEFORM -Pwb_sevenseg.CNT_VALUE=4

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

sim: $(MODULE).py
