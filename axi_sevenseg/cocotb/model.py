import cocotb
from cocotb.result import TestFailure
from cocotb.triggers import Timer, RisingEdge

# Lookup between digit selection signal and digit index
an_lookup = {127: 7, 191: 6, 223: 5, 239: 4, 247: 3, 251: 2, 253: 1, 254: 0}
# Lookup between seven segment and the digit
ca_lookup = {64: 0, 121: 1, 36: 2, 48: 3, 25: 4, 18: 5, 2: 6, 120: 7, 0: 8,
             24: 9, 8: 10, 3: 11, 70: 12, 33: 13, 6: 14, 14: 15}

# The model tracks to output of the DUT and checks if it matches
# the expected value (as set externally)
class SevenSegment(object):
    def __init__(self, dut):
        self.dut = dut
        self.value = 0
        self.observations = {}
        for k in an_lookup.keys():
            self.observations[an_lookup[k]] = 0

    @cocotb.coroutine
    def monitor(self):
        while True:
            # Verify on each rising clock edge
            yield RisingEdge(self.dut.i_wb_clk)
            # The bit paaterns need to be translated
            an = self.dut.o_an.value.integer
            ca = self.dut.o_ca.value.integer
            if an not in an_lookup.keys():
                self.dut._log.error("Unexpected an value: {}".format(an))
                raise TestFailure()
            an = an_lookup[an]

            if ca not in ca_lookup.keys():
                self.dut._log.error("Unexpected digits: {}".format(ca))
                raise TestFailure()
            ca = ca_lookup[ca]

            # Extract expected digit
            expected = (self.value >> an*4) & 0xf

            if ca != expected:
                self.dut._log.error("Expected {}, got {}".format(expected, ca))
                raise TestFailure()

            # Count up how often each index was seen
            self.observations[an] += 1
