## Approximate-timing XDC for xc7a200tfbv484-1
## Arbitrary legal package pins, not tied to any specific board.

## Clock (MRCC-capable pin)
set_property PACKAGE_PIN W11 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## Reset
set_property PACKAGE_PIN W12 [get_ports {rst_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst_n}]

## Enable
set_property PACKAGE_PIN V13 [get_ports {ena}]
set_property IOSTANDARD LVCMOS33 [get_ports {ena}]

## ui_in[7:0] - dedicated inputs
set_property PACKAGE_PIN V14 [get_ports {ui_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[0]}]

set_property PACKAGE_PIN U15 [get_ports {ui_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[1]}]

set_property PACKAGE_PIN V15 [get_ports {ui_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[2]}]

set_property PACKAGE_PIN T14 [get_ports {ui_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[3]}]

set_property PACKAGE_PIN T15 [get_ports {ui_in[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[4]}]

set_property PACKAGE_PIN W15 [get_ports {ui_in[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[5]}]

set_property PACKAGE_PIN W16 [get_ports {ui_in[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[6]}]

set_property PACKAGE_PIN T16 [get_ports {ui_in[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[7]}]

## uo_out[7:0] - dedicated outputs
set_property PACKAGE_PIN U16 [get_ports {uo_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[0]}]

set_property PACKAGE_PIN Y16 [get_ports {uo_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[1]}]

set_property PACKAGE_PIN AA16 [get_ports {uo_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[2]}]

set_property PACKAGE_PIN AB16 [get_ports {uo_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[3]}]

set_property PACKAGE_PIN AB17 [get_ports {uo_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[4]}]

set_property PACKAGE_PIN AA13 [get_ports {uo_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[5]}]

set_property PACKAGE_PIN AB13 [get_ports {uo_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[6]}]

set_property PACKAGE_PIN AA15 [get_ports {uo_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[7]}]

## uio[7:0] - extra inputs for approximate timing only
set_property PACKAGE_PIN AB15 [get_ports {uio[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[0]}]

set_property PACKAGE_PIN Y13 [get_ports {uio[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[1]}]

set_property PACKAGE_PIN AB11 [get_ports {uio[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[2]}]

set_property PACKAGE_PIN AB12 [get_ports {uio[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[3]}]

set_property PACKAGE_PIN AA9 [get_ports {uio[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[4]}]

set_property PACKAGE_PIN AB10 [get_ports {uio[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[5]}]

set_property PACKAGE_PIN AA10 [get_ports {uio[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[6]}]

set_property PACKAGE_PIN AA11 [get_ports {uio[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[7]}]
