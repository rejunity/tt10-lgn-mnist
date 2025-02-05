TOP = icebreaker

all: $(TOP).rpt $(TOP).bin

%.json: %.v
	yosys -DSYNTH -p 'synth_ice40 -top top -json $@' $<

icebreaker.json: icebreaker.v ../../src/project.v ../../src/net.v ../../src/popcount.v oled.v
	yosys -DSYNTH -p "read_verilog $^; synth_ice40 -top top -json $@; ltp"

$(TOP).bin: $(TOP).asc digit.hex
$(TOP).asc: $(TOP).json digit.hex

%.asc: %.json icebreaker.pcf
	nextpnr-ice40 --up5k --freq 6 --asc $@ --pcf icebreaker.pcf --json $<

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d up5k -mtr $@ $<

%_tb: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.json
	yosys -DSYNTH -p 'read_json $^; write_verilog $@'

%_syntb: %_tb.v %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

prog: $(TOP).bin
	iceprog $<

sudo-prog: $(TOP).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -f $(TOP).json $(TOP).asc $(TOP).rpt $(TOP).bin
	rm -f $(TOP)_tb $(TOP)_tb.vcd $(TOP)_syn.v $(TOP)_syntb $(TOP)_syntb.vcd

.SECONDARY:
.PHONY: all prog clean