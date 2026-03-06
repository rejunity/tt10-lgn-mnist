#!/usr/bin/env bash
set -ex
yosys -p "tcl synth_lut2/synth_generic.tcl 2 generic.json" icebreaker.v ../../src/project.v ../../src/net.v ../../src/popcount.v
#nextpnr-generic --top top --pre-pack simple.py --pre-place simple_timing.py --json generic.json --post-route bitstream.py --write pnr_generic.json
#yosys -p "read_verilog -lib synth/prims.v; read_json pnr_generic.json; dump -o generic.il; show -format png -prefix generic"
