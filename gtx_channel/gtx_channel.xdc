################################################################################
# IO constraints
################################################################################
# clk200:0.p
set_property LOC AB11 [get_ports {clk200_p}]
set_property IOSTANDARD LVDS [get_ports {clk200_p}]

# clk200:0.n
set_property LOC AC11 [get_ports {clk200_n}]
set_property IOSTANDARD LVDS [get_ports {clk200_n}]

# usb3a_tx:0.p
set_property LOC K2 [get_ports {usb3a_tx_p}]

# usb3a_tx:0.n
set_property LOC K1 [get_ports {usb3a_tx_n}]

# usb3a_rx:0.p
set_property LOC L4 [get_ports {usb3a_rx_p}]

# usb3a_rx:0.n
set_property LOC L3 [get_ports {usb3a_rx_n}]

# user_led:0
set_property LOC U9 [get_ports {user_led0}]
set_property IOSTANDARD LVCMOS15 [get_ports {user_led0}]
set_property SLEW SLOW [get_ports {user_led0}]

# user_led:1
set_property LOC V12 [get_ports {user_led1}]
set_property IOSTANDARD LVCMOS15 [get_ports {user_led1}]
set_property SLEW SLOW [get_ports {user_led1}]

# user_led:2
set_property LOC V13 [get_ports {user_led2}]
set_property IOSTANDARD LVCMOS15 [get_ports {user_led2}]
set_property SLEW SLOW [get_ports {user_led2}]

# user_led:3
set_property LOC W13 [get_ports {user_led3}]
set_property IOSTANDARD LVCMOS15 [get_ports {user_led3}]
set_property SLEW SLOW [get_ports {user_led3}]

################################################################################
# Design constraints
################################################################################

# set_property CONFIG_VOLTAGE 1.8 [current_design]
# 
# set_property CFGBVS GND [current_design]
# 
# get_property INTERNAL_VREF 0.750 [get_iobanks 32]
# 
# set_property INTERNAL_VREF 0.750 [get_iobanks 33]
# 
# set_property INTERNAL_VREF 0.750 [get_iobanks 34]
# 
# set_property DCI_CASCADE {32} [get_iobanks 34]
# 
# set_property BITSTREAM.CONFIG.CONFIGRATE 22 [current_design]
# 
# set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]
# 
# set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
# 
# set_property SEVERITY {Warning} [get_drc_checks REQP-56]
# 
# ################################################################################
# # Clock constraints
# ################################################################################
# 
# 
# create_clock -name clk200_p -period 5.0 [get_ports clk200_p]
# 
# create_clock -name tx_clk -period 20.0 [get_nets tx_clk]
# 
# create_clock -name rx_clk -period 20.0 [get_nets rx_clk]
# 
# ################################################################################
# # False path constraints
# ################################################################################
# 
# 
# set_false_path -quiet -through [get_nets -hierarchical -filter {mr_ff == TRUE}]
# 
# set_false_path -quiet -to [get_pins -filter {REF_PIN_NAME == PRE} -of_objects [get_cells -hierarchical -filter {ars_ff1 == TRUE || ars_ff2 == TRUE}]]
# 
# set_max_delay 2 -quiet -from [get_pins -filter {REF_PIN_NAME == C} -of_objects [get_cells -hierarchical -filter {ars_ff1 == TRUE}]] -to [get_pins -filter {REF_PIN_NAME == D} -of_objects [get_cells -hierarchical -filter {ars_ff2 == TRUE}]]
# 
# set_clock_groups -group [get_clocks -include_generated_clocks -of [get_nets tx_clk]] -group [get_clocks -include_generated_clocks -of [get_nets rx_clk]] -asynchronous
# 
# set_clock_groups -group [get_clocks -include_generated_clocks -of [get_nets sys_clk]] -group [get_clocks -include_generated_clocks -of [get_nets tx_clk]] -asynchronous
# 
# set_clock_groups -group [get_clocks -include_generated_clocks -of [get_nets sys_clk]] -group [get_clocks -include_generated_clocks -of [get_nets rx_clk]] -asynchronous
