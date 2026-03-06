## Approximate-timing XDC for xc7a35tcsg324-1
## Arbitrary legal package pins, not tied to any specific board.

## Clock
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## Reset
set_property PACKAGE_PIN D3 [get_ports {rst_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst_n}]

## Enable
set_property PACKAGE_PIN F4 [get_ports {ena}]
set_property IOSTANDARD LVCMOS33 [get_ports {ena}]

## ui_in[7:0] - dedicated inputs
set_property PACKAGE_PIN C2 [get_ports {ui_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[0]}]

set_property PACKAGE_PIN C1 [get_ports {ui_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[1]}]

set_property PACKAGE_PIN H2 [get_ports {ui_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[2]}]

set_property PACKAGE_PIN G2 [get_ports {ui_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[3]}]

set_property PACKAGE_PIN H1 [get_ports {ui_in[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[4]}]

set_property PACKAGE_PIN G1 [get_ports {ui_in[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[5]}]

set_property PACKAGE_PIN F1 [get_ports {ui_in[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[6]}]

set_property PACKAGE_PIN E1 [get_ports {ui_in[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ui_in[7]}]

## uo_out[7:0] - dedicated outputs
set_property PACKAGE_PIN G6 [get_ports {uo_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[0]}]

set_property PACKAGE_PIN F6 [get_ports {uo_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[1]}]

set_property PACKAGE_PIN G4 [get_ports {uo_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[2]}]

set_property PACKAGE_PIN G3 [get_ports {uo_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[3]}]

set_property PACKAGE_PIN J4 [get_ports {uo_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[4]}]

set_property PACKAGE_PIN H4 [get_ports {uo_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[5]}]

set_property PACKAGE_PIN J3 [get_ports {uo_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[6]}]

set_property PACKAGE_PIN J2 [get_ports {uo_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uo_out[7]}]

## uio[7:0] - extra inputs for approximate timing only
set_property PACKAGE_PIN K2 [get_ports {uio[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[0]}]

set_property PACKAGE_PIN K1 [get_ports {uio[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[1]}]

set_property PACKAGE_PIN H6 [get_ports {uio[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[2]}]

set_property PACKAGE_PIN H5 [get_ports {uio[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[3]}]

set_property PACKAGE_PIN J5 [get_ports {uio[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[4]}]

set_property PACKAGE_PIN T5 [get_ports {uio[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[5]}]

set_property PACKAGE_PIN T4 [get_ports {uio[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[6]}]

set_property PACKAGE_PIN N5 [get_ports {uio[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {uio[7]}]

