# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

X = \
[[1, 1],
 [1, 0],
 [0, 1],
 [0, 0]]

Y = \
[[1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
 [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
 [0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
 [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]]

def array_to_bin(arr):
    # print(arr)
    out = 0
    for i in range(len(arr)):
        out |= (1<<i) if arr[i] > 0 else 0
    return out

def assert_output(dut, y):
    dut._log.info(f"Expected: {bin(array_to_bin(y[0:8]))}, {bin(array_to_bin(y[8:15]))}")
    dut._log.info(f"Computed: {dut.uo_out.value}, {dut.uio_out.value}")
    assert dut.uio_out.value == array_to_bin(y[8:15])
    assert dut.uo_out.value  == array_to_bin(y[0: 8])

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    for x, y in zip(X, Y):
        # print(x, y, y[0:8], y[8:15])
        dut.ui_in.value = array_to_bin(x)
        dut._log.info(f"Input: {bin(array_to_bin(x))}")
        dut.uio_in.value = 0
        await ClockCycles(dut.clk, 1)
        assert_output(dut, y)

