#!/usr/bin/env bash
set -ex
yosys -p "tcl synth_lut6/synth_generic.tcl 6 generic_lut6.json" icebreaker.v ../../src/project.v ../../src/net.v ../../src/popcount.v
#nextpnr-generic --top top --pre-pack simple_lut6.py --pre-place simple_timing.py --json generic_lut6.json --post-route bitstream_lut6.py --write pnr_generic_lut6.json
# yosys -p "read_verilog -lib synth_lut6/prims.v; read_json pnr_generic_lut6.json; dump -o generic_lut6.il; show -format png -prefix generic_lut6"
