set_property LOC AB11 [get_ports clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk_p}]

set_property LOC AC11 [get_ports clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk_n}]

set_property LOC AD23 [get_ports button]
set_property IOSTANDARD SSTL15 [get_ports {button}]

set_property LOC U9 [get_ports led]
set_property IOSTANDARD LVCMOS15 [get_ports {led}]

set_property LOC V12 [get_ports locked_led]
set_property IOSTANDARD LVCMOS15 [get_ports {locked_led}]

set_property LOC W10 [get_ports delay_out0]
set_property IOSTANDARD LVCMOS15 [get_ports {delay_out0}]

set_property LOC W9 [get_ports delay_out1]
set_property IOSTANDARD LVCMOS15 [get_ports {delay_out1}]

set_property LOC V9 [get_ports clkout0]
set_property IOSTANDARD LVCMOS15 [get_ports {clkout0}]

set_property LOC W8 [get_ports clkout1]
set_property IOSTANDARD LVCMOS15 [get_ports {clkout1}]

create_clock -name clk200 -period 5.0 [get_nets clk_in]

# for vivado: to see what happens when ODDR is not connected to ODELAY
#set_property IS_ENABLED 0 [get_drc_checks {REQP-131}]
