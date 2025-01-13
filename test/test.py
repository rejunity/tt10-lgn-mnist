# SPDX-FileCopyrightText: © 2024 Renaldas Zioma
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

# X = \
# [[1, 1],
#  [1, 0],
#  [0, 1],
#  [0, 0]]

# Y = \
# [[1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
#  [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
#  [0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
#  [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]]

X = \
[[0] * 256,
 # [0, 1] * 128,
 [1] * 256]

# Y = \
# [[1832],
#  [1785],
#  [1773]] # 24K gates

# Y = \
# [[1996],
#  [1978],
#  [1988]] # 20K gates

# Y = \
# [[2007],
#  [2005],
#  [2014]] # 16K gates

# Y = \
# [[1968],
#  [1983],
#  [2015]] # 12K gates


############################## TEST NETS
# Y = \
# [[   0],
#  # [   126],
#  [   0]] # ../src/test_XOR_...v

# Y = \
# [[   0],
#  [   256]] # ../src/test_OR_...v, ../src/test_AND_...v
 
# Y = \
# [[ 134],
#  [ 133],
#  [ 131]] # ../src/test_rnd_d0r1_8x256_256i_256o.v

# Y = \
# [[ 141],
#  [ 136],
#  [ 136]] # ../src/test_rnd_d0r4_8x256_256i_256o.v

# Y = \
# [[ 121],
#  [ 126],
#  [ 137]] # ../src/test_rnd_d4r1_8x256_256i_256o.v

# Y = \
# [[ 151],
#  [ 143]] # ../src/test_rnd_d16r1_8x256_256i_256o.v

# Y = \
# [[ 119],
#  [ 125],
#  [ 113]] # ../src/test_rnd_d16r1_8x256_256i_256o.v

# Y = \
# [[   484],
#  [   493]] # ../src/test_rnd_d04r01_8x1024_256i_1024o.v

# Y = \
# [[   521],
#  [   520]] # ../src/test_rnd_d16r01_8x1024_256i_1024o.v

# Y = \
# [[ 1051],
#  [ 1046]] # ../src/test_rnd_d16r01_8x2048_256i_1024o.v

Y = \
[[ 1998],
 [ 2007]] # ../src/test_rnd_d16r01_4x4096_256i_1024o.v

def split_array(lst, chunk_size=8):
    return [lst[i:i + chunk_size] for i in range(0, len(lst), chunk_size)]

def array_to_bin(arr):
    out = 0
    for i in range(len(arr)):
        out |= (1<<i) if arr[i] > 0 else 0
    return out

def assert_output(dut, y):
    print(y)
    expected = sum(y)
    computed = dut.uio_out.value * 256 + dut.uo_out.value
    dut._log.info(f"Expected: {expected}")
    dut._log.info(f"Computed: {computed}")
    assert expected == computed

    # dut._log.info(f"Expected: {bin(array_to_bin(y[0:8]))}, {bin(array_to_bin(y[8:15]))}")
    # dut._log.info(f"Computed: {dut.uo_out.value}, {dut.uio_out.value}")
    # assert dut.uio_out.value == array_to_bin(y[8:15])
    # assert dut.uo_out.value  == array_to_bin(y[0: 8])

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

    dut._log.info("Test network")
    # Set the input values you want to test
    for x, y in zip(X, Y):
        # dut._log.info(f"Input: {bin(array_to_bin(x))}")
        dut._log.info(f"Input: {x}")
        dut._log.info("Clear input buffer")
        dut.ui_in.value = 0
        dut.uio_in.value = 0
        await ClockCycles(dut.clk, 256//8)
        dut._log.info(f"Set input buffer, {len(x)} bits")
        for block_of_8 in split_array(x, 8):
            print(bin(array_to_bin(block_of_8)))
            dut.ui_in.value = array_to_bin(block_of_8)
            # dut.ui_in.value = 0 if digit == 0 else 1
            await ClockCycles(dut.clk, 1)

        dut.uio_in.value = 128
        await ClockCycles(dut.clk, 1)

        assert_output(dut, y)
