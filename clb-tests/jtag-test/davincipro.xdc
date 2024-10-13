# Alientek Davinci Pro Board

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property LOC V9 [get_ports {led_o[0]}]
set_property IOSTANDARD SSTL135 [get_ports {led_o[0]}]

set_property LOC Y8 [get_ports {led_o[1]}]
set_property IOSTANDARD SSTL135 [get_ports {led_o[1]}]

set_property LOC Y7 [get_ports {led_o[2]}]
set_property IOSTANDARD SSTL135 [get_ports {led_o[2]}]

set_property LOC W7 [get_ports {led_o[3]}]
set_property IOSTANDARD SSTL135 [get_ports {led_o[3]}]
