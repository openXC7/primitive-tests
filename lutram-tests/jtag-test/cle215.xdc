# SQRL Acorn CLE215(+)
# FPGA part: xc7a200tfbg484-3
# cfgmem part: s25fl128sxxxxxx1 (SPIx4)

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# user_led:0
set_property LOC G3 [get_ports {led_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[0]}]

# user_led:1
set_property LOC H3 [get_ports {led_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[1]}]

# user_led:2
set_property LOC G4 [get_ports {led_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[2]}]

# user_led:3
set_property LOC H4 [get_ports {led_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[3]}]
