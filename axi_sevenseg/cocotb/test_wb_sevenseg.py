import random

import cocotb
from cocotb.result import TestFailure
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

from model import SevenSegment

@cocotb.coroutine
def configure(dut, value):
    yield RisingEdge(dut.i_wb_clk)
    dut.i_wb_sel <= 0xf
    dut.i_wb_we <= 1
    dut.i_wb_cyc <= 1
    dut.i_wb_stb <= 1
    dut.i_wb_dat <= value
    yield RisingEdge(dut.i_wb_clk)
    while dut.o_wb_ack.value == 0:
        yield RisingEdge(dut.i_wb_clk)
    dut.i_wb_cyc <= 0
    dut.i_wb_stb <= 0


@cocotb.test()
def sevenseg_test(dut, tests=20):
    dut.i_wb_cyc = 0
    dut.i_wb_stb = 0
    c = Clock(dut.i_wb_clk, 2)
    cocotb.fork(c.start())
    dut.i_wb_rst = 1
    yield Timer(10)
    dut.i_wb_rst = 0

    model = SevenSegment(dut)
    yield configure(dut, 0)
    model.value = 0
    yield Timer(10)

    monitor = cocotb.fork(model.monitor())

    for i in range(tests):
        yield Timer(random.randint(1,20))
        v = random.getrandbits(32)
        yield configure(dut, v)
        yield RisingEdge(dut.i_wb_clk)
        model.value = v

    monitor.kill()

    dut._log.info("observations: {}".format(model.observations))

