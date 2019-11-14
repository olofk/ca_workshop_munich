import random

import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

from model import SevenSegment

# This is the co-routine which configures the DUT over
# the bus interface with a given value
@cocotb.coroutine
def configure(dut, value):
    # wait until after next rising clock edge
    yield RisingEdge(dut.i_wb_clk)
    # Set pins
    dut.i_wb_sel <= 0xf
    dut.i_wb_we <= 1
    dut.i_wb_cyc <= 1
    dut.i_wb_stb <= 1
    dut.i_wb_dat <= value
    # wait until the next clock edge and check
    # ack until we see it
    yield RisingEdge(dut.i_wb_clk)
    while dut.o_wb_ack.value == 0:
        yield RisingEdge(dut.i_wb_clk)
    dut.i_wb_cyc <= 0
    dut.i_wb_stb <= 0


# This is the actual test that is picked up
@cocotb.test()
def sevenseg_test(dut, tests=20):
    dut.i_wb_cyc = 0
    dut.i_wb_stb = 0
    # Clock
    c = Clock(dut.i_wb_clk, 2)
    cocotb.fork(c.start())

    # Reset cycle
    dut.i_wb_rst = 1
    yield Timer(10)
    dut.i_wb_rst = 0

    # Instantiate model of seven segment
    model = SevenSegment(dut)

    # Initialize model and DUT to same state
    yield configure(dut, 0)
    model.value = 0
    yield Timer(10)

    # Let model monitor DUT output
    monitor = cocotb.fork(model.monitor())

    # Run given number of tests
    for i in range(tests):
        # Wait states
        yield Timer(random.randint(1,20))
        # Random value to display
        v = random.getrandbits(32)
        yield configure(dut, v)
        yield RisingEdge(dut.i_wb_clk)
        model.value = v

    # Terminatre monitor
    monitor.kill()

    # Display how often each digit has been seen
    dut._log.info("observations: {}".format(model.observations))
