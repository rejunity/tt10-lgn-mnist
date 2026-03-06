#!/usr/bin/env bash
set -ex

PTH=/Users/rej/Dev/TinyTapeout/TrainableLogicGateNetworks.my.git/__paper2_pth/
LUTN=4
XILINX_FPGA=~/nextpnr-xilinx/xilinx/xc7a35t.bin

TYPE=mnist
CFG=cfg_mnist_4000
NAME=20260211-025752_binTestAcc9763_seed246927_epochs200_1x4000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
# time yosys -p "read_verilog ${CFG}_countbits.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_CB_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ecp5 -abc9 -top tt_um_rejunity_lgn_mnist -json ecp5.json" 2>&1 | tee ${TYPE}_LUTX4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
# time yosys -p "read_verilog ${CFG}_countbits.v project.v net.v; synth_ecp5 -abc9 -top tt_um_rejunity_lgn_mnist -json ecp5.json" 2>&1 | tee ${TYPE}_LUTX4_CB_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "read_verilog ${CFG}_countbits.v project.v net.v; synth_xilinx -abc9 -top tt_um_rejunity_lgn_mnist -json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_CB_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}_countbits.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_CB_${NAME}.log | grep -E "ERROR|^===|^--|LUT"


CFG=cfg_mnist_8000
NAME=20260211-021224_binTestAcc9847_seed595175_epochs200_1x8000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG},v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"


CFG=cfg_mnist_8000
NAME=20260211-102805_binTestAcc9879_seed670011_epochs200_4x8000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"

CFG=cfg_mnist_16000
NAME=20260211-071156_binTestAcc9894_seed93815_epochs200_2x16000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"


# DIFFLOGIC
TYPE=difflogic_fmnist
CFG=cfg_fmnist_8000
NAME=20260306-101956_binTestAcc8856_seed992072_6x8000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"


CFG=cfg_fmnist_64000
NAME=20260306-065016_binTestAcc9027_seed774419_6x64000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"



TYPE=cifar10
CFG=cfg_cifar_8000
NAME=20260304-041039_binTestAcc5489_seed846330_epochs200_1x8000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# # time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"

CFG=cfg_cifar_64000
NAME=20260305-205252_binTestAcc5806_seed1013572_epochs200_1x64000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"

CFG=cfg_cifar_128000
NAME=20260304-143203_binTestAcc6076_seed48695_epochs200_2x128000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# # time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"





TYPE=fmnist
CFG=cfg_fmnist_8000
NAME=20260304-054848_binTestAcc9003_seed339358_epochs200_1x8000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"

CFG=cfg_fmnist_16000
NAME=20260304-142723_binTestAcc9003_seed503866_epochs200_2x16000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"

CFG=cfg_fmnist_32000
NAME=20260304-151343_binTestAcc9039_seed72612_epochs200_2x32000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"

CFG=cfg_fmnist_64000
NAME=20260304-054340_binTestAcc9066_seed555515_epochs200_2x64000_b256_lr75_interconnect.pth
python3 pth_to_verilog.py $PTH/$TYPE/$NAME
# time yosys -p "read_verilog ${CFG}.v project.v net.v; synth_ice40 -top tt_um_rejunity_lgn_mnist -json ice40.json" 2>&1 | tee ${TYPE}_LUTC4_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time yosys -p "read_verilog ${CFG}.v ../fpga/xilinx/xilinx.v project.v net.v; synth_xilinx -abc9 -top top; write_json xilinx.json" 2>&1 | tee ${TYPE}_LUTX6_${NAME}.log | grep -E "ERROR|^===|^--|LUT|LCs:"
time nextpnr-xilinx --json xilinx.json --chipdb $XILINX_FPGA --xdc ../fpga/xilinx/xilinx.xdc | tee XILINX_${TYPE}_${NAME}.log | grep -E "ERROR|^===|^--|LCs:|frequency|routing"
# time yosys -p "tcl ../fpga/generic/synth_lut$LUTN/synth_generic.tcl $LUTN ../fpga/generic/generic.json" ${CFG}.v project.v net.v 2>&1 | tee ${TYPE}_LUT${LUTN}_${NAME}.log | grep -E "ERROR|^===|^--|LUT"
