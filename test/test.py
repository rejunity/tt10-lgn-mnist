# SPDX-FileCopyrightText: © 2024 Renaldas Zioma
# SPDX-License-Identifier: Apache-2.0

import os
import numpy as np

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

gates_value = os.getenv('GATES')
GATE_LEVEL_SIMULATION = not gates_value in (None, "no")
print("GATES", GATE_LEVEL_SIMULATION)


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


# Y = \
# [[1968],
#  [1983],
#  [2015]] # 12K gates

# Y = \
# [[166],
#  [123]] # 8K gates final_20250113-141316_acc4865_seed775741_epochs50_dispersion16_8x1024.v
# Y = \
# [[292],
#  [181]] # 8K gates final_20250113-143813_acc3391_seed259890_epochs30_dispersion4_8x1024.v
# Y = \
# [[215],
#  [173]] # 8K gates final_20250114-123035_acc5871_seed382310_epochs300_dispersion16_1020-1020-1020-1020-1020-1020-1020-1020.v
# Y = \
# [[325],
#  [264]] # 8K gates final_20250114-102550_acc8068_seed1873_epochs300_dispersion64_1020-1020-1020-1020-1020-1020-1020-1020.v
# Y = \
# [[422],
#  [469]] # 8K gates barabasi_20250114-162804_acc7495_seed493279_epochs10_dispersion16_1020-1020-1020-1020-1020-1020-1020-1020.v
# Y = \
# [[414],
#  [423]] # 8K gates barabasi_20250115-080837_acc7913_seed176567_epochs100_dispersion128_1020-1020-1020-1020-1020-1020-1020-1020.v
Y =        "../src/barabasi_20250115-080837_acc7913_seed176567_epochs100_dispersion128_1020-1020-1020-1020-1020-1020-1020-1020with_dataset.npz"
# Y = \
# [[857],
#  [942]] # 16K gates barabasi_20250115-050146_acc8915_seed803984_epochs100_dispersion64_2040-2040-2040-2040-2040-2040-2040-2040.v
# Y =          "../src/barabasi_20250115-050146_acc8915_seed803984_epochs100_dispersion64_2040-2040-2040-2040-2040-2040-2040-2040with_dataset.npz"

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

# Y = \
# [[ 1998],
#  [ 2007]] # ../src/test_rnd_d16r01_4x4096_256i_1024o.v

### Load test data, if Y contains file name ###################################
if isinstance(Y, str): 
    data = np.load(Y)
    X = data["input"]
    Y = data["output"]
    print(X.shape, Y.shape)
###############################################################################

def split_array(lst, chunk_size=8):
    return [lst[i:i + chunk_size] for i in range(0, len(lst), chunk_size)]

def array_to_bin(arr):
    return ''.join(arr.astype(int).astype(str))

def assert_output(dut, y):
    does_y_containt_already_summed_values = len(y) == 0 and y[0] > 0
    if not does_y_containt_already_summed_values and \
       not GATE_LEVEL_SIMULATION: # Gate level simulation prevents to check the output
                                  # of the network, but do it when we can for extra testing
        # network output wire array might be larger than the output in the dataset
        # take only first bits (in string format)
        assert str(dut.tt_um_rejunity_lgn_mnist.y.value)[::-1].startswith(array_to_bin(y))

    expected = int(sum(y))
    computed = dut.uio_out.value * 256 + dut.uo_out.value
    dut._log.info(f"Expected: {expected}")
    dut._log.info(f"Computed: {computed}")
    assert expected == computed

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
    for x, y in zip(X[:8], Y[:8]): # dataset can contain a lot of test samples
                                   # take only 8 for tractable speed of the test
        x = x[::-1] # reverse input data for uploading via the shift register
        dut._log.info(f"Input: {array_to_bin(x)}")
        dut._log.info("Clear input buffer")
        dut.ui_in.value = 0
        dut.uio_in.value = 0
        await ClockCycles(dut.clk, 256//8)
        dut._log.info(f"Set input buffer, {len(x)} bits")
        for block_of_8 in split_array(x, 8):
            print(array_to_bin(block_of_8))
            dut.ui_in.value = int(array_to_bin(block_of_8), 2)
            await ClockCycles(dut.clk, 1)

        dut.uio_in.value = 128
        await ClockCycles(dut.clk, 1)

        dut._log.info(f"Expected output of the last layer: {array_to_bin(y)}")

        assert_output(dut, y)
