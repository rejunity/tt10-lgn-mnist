# SPDX-FileCopyrightText: © 2024 Renaldas Zioma
# SPDX-License-Identifier: Apache-2.0

import os
import numpy as np

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


### LOAD Y FROM NET.V WHEN Y UNDEFINED
try:
    Y
except NameError:
    src_dir = os.getenv("SRC_DIR")
    if not src_dir:
        raise EnvironmentError("SRC_DIR is not set.")
    net_v_path = os.path.join(os.path.abspath(src_dir), "net.v")
    if not os.path.exists(net_v_path):
        raise FileNotFoundError(f"File not found: {net_v_path}")
    with open(net_v_path, "r") as file:
        first_net_v_line = file.readline().strip()
    prefix = "// Generated from: "
    if first_net_v_line.startswith(prefix):
        Y = os.path.join(os.path.abspath(src_dir),first_net_v_line[len(prefix):])
    else:
        raise IOError("Unexpected net.v first line")


gates_value = os.getenv('GATES')
GATE_LEVEL_SIMULATION = not gates_value in (None, "no")
print("GATES", GATE_LEVEL_SIMULATION)

CLEAR_BETWEEN_TEST_SAMPLES = False
# CLEAR_BETWEEN_TEST_SAMPLES = True
# CLEAR_WITH_ALTERNATING_PATTERN = False
CLEAR_WITH_ALTERNATING_PATTERN = True

# X = [[1, 1], [1, 0], [0, 1], [0, 0]]
# Y =[[1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]]

X = \
[[0] * 256,
 [1] * 256]

# Y =        "../src/barabasi_20250115-080837_acc7913_seed176567_epochs100_dispersion128_1020-1020-1020-1020-1020-1020-1020-1020with_dataset.npz"
# 8K gates

# Y =          "../src/barabasi_20250115-050146_acc8915_seed803984_epochs100_dispersion64_2040-2040-2040-2040-2040-2040-2040-2040with_dataset.npz"
# 16K gates


# Y =        "../src/binarized_20250122-110005_acc9041_seed876599_epochs300_3x1300_b256_lrm10-1with_dataset.npz"
# 10K gates
# Multi-Input combinational cell: 7797
# Util: 26.044 % [INFO GPL]
# NewTargetDensity: 0.8221
# ICESTORM_LC:    4713/   5280    89%   Router1 time 165.76s

# Y =        "../src/barabasi_20250116-110050_acc8484_seed742947_epochs50_dsp128_8x1500_b256_lrm4-4with_dataset.npz"
# 12K gates, Suggested target density: 0.31
# Multi-Input combinational cell: 9095
# Util: 30.209 %
# NewTargetDensity: 0.841
# ICESTORM_LC:    5064/   5280   104%

# Y =        "../src/baralizm_20250116-123948_acc9424_seed1022128_epochs50_dsp128_3x4000_b256_lrm5-1with_dataset.npz"
# 12K gates, Suggested target density: 0.79

# Y =        "../src/baralizm_20250117-183715_acc9336_seed522333_epochs300_dsp128_3x3000_b256_lrm10-1with_dataset.npz"
# 9K gates, Suggested target density:  0.59

# Y =        "../src/baralizm_20250118-072438_acc9263_seed954361_epochs300_dsp128_3x2500_b256_lrm10-1with_dataset.npz"
# 7.5K gates, Suggested target density: 0.3 (was 0.49)
# Multi-Input combinational cell 6483
# Congestion: 98.86% (fails)
# SavedTargetDensity: 0.5144


# Y =        "../src/baralizm_20250118-065915_acc9141_seed115798_epochs300_dsp128_3x2000_b256_lrm10-1with_dataset.npz"
# 6K gates, Suggested target density:  0.39
# Multi-Input combinational cell: 11656
# With FA/HA, multi-Input combinational cell: 6170 (TargetDensity: 0.705, congestion:  82.75%) (8352 total cells, 3213 ha/fa. Utilisation 26.079 %, wire 1216268)
# ICESTORM_LC:    6289/   5280   119%

# Y =        "../src/binarized_20250124-150213_acc9269_seed521206_epochs300_3x2550_b256_lrm10-1_pass48with_dataset.npz"
# 7.7K gates, utilisation: 24.61%, wire: 582633
# Multi-Input combinational cell 4769
# Congestion: 38.96%
# TargetDensity: 0.25
# ICESTORM_LC:    6577/   5280   124%

# Y =        "../src/binarized_20250124-152724_acc9449_seed470315_epochs100_3x2550_b256_lrm10-1_pass0with_dataset.npz"
# 7.7K gates, utilisation: 29.01%, wire: 816369
# Multi-Input combinational cell 6262
# Congestion: 54.14%  
# SavedTargetDensity: 0.3099
# ICESTORM_LC:    8040/   5280   152%

Y =        "../src/binarized_20250122-110005_acc9041_seed876599_epochs300_3x1300_b256_lrm10-1with_dataset.npz"


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
    X = data["input"][20:]
    Y = data["output"][20:]
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

    categories = np.sum(y.reshape(10, -1), -1)

    expected = np.argmax(categories)
    computed = dut.uio_out.value & 15
    dut._log.info(f"Expected category: {expected}")
    dut._log.info(f"Computed category: {computed}")

    assert expected == computed

    expected = int(categories[expected])
    computed = dut.uo_out.value & 255
    dut._log.info(f"Expected value: {expected}")
    dut._log.info(f"Computed value: {computed}")

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

    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 256//8)

    dut._log.info("Test network")
    # Set the input values you want to test
    alt = 0
    for x, y in zip(X[:8], Y[:8]): # dataset can contain a lot of test samples
                                   # take only 8 for tractable speed of the test
        x = x[::-1] # reverse input data for uploading via the shift register
        dut._log.info(f"Input: {array_to_bin(x)}")
        dut._log.info("Clear input buffer")
        dut.ui_in.value = 0 if alt == 0 else 255
        dut.uio_in.value = 0
        def category_index(): return dut.uio_out.value & 15
        def category_value(): return dut.uo_out.value & 255
        if CLEAR_BETWEEN_TEST_SAMPLES:
            for i in range(256//8):
                if i % 2 == 1:
                    if alt == 0:
                        print(f"0000000000000000 best index: {category_index()} value: {category_value()}")
                    else:
                        print(f"1111111111111111 best index: {category_index()} value: {category_value()}")
                await ClockCycles(dut.clk, 1)
            alt = 1-alt if CLEAR_WITH_ALTERNATING_PATTERN else alt

        dut._log.info(f"Set input buffer, {len(x)} bits")
        i = 0
        for block_of_8 in split_array(x, 8):
            print(array_to_bin(block_of_8), end="")
            if i % 2 == 1:
                print(f" best index: {category_index()} value: {category_value()}")
            dut.ui_in.value = int(array_to_bin(block_of_8), 2)
            await ClockCycles(dut.clk, 1)
            i += 1

        dut.ui_in.value = 0
        dut.uio_in.value = 128
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"Computed best index: {category_index()} value: {category_value()}")

        dut._log.info(f"Expected output of the last layer: {array_to_bin(y)}")

        assert_output(dut, y)
