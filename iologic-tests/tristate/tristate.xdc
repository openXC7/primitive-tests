set_property LOC AB11 [get_ports clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk_p}]

set_property LOC AC11 [get_ports clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk_n}]

# KEY2
set_property LOC AC16 [get_ports button]
set_property IOSTANDARD SSTL15 [get_ports {button}]

# KEY3
set_property LOC C24 [get_ports tristate_button]
set_property IOSTANDARD SSTL15 [get_ports {tristate_button}]

# LED0
set_property LOC AA2 [get_ports serdes_out]
set_property IOSTANDARD SSTL15 [get_ports {serdes_out}]

# LED2
set_property LOC W10 [get_ports serdes_in]
set_property IOSTANDARD SSTL15 [get_ports {serdes_in}]

# LED3
set_property LOC Y10 [get_ports locked_led]
set_property IOSTANDARD LVCMOS15 [get_ports {locked_led}]

# LED4
set_property LOC AE10 [get_ports led]
set_property IOSTANDARD LVCMOS15 [get_ports {led}]

# LED5
set_property LOC W11 [get_ports diff_led_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {diff_led_n}]

# LED6
set_property LOC V11 [get_ports diff_led_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {diff_led_p}]

# LED7
set_property LOC Y12 [get_ports status_led]
set_property IOSTANDARD SSTL15 [get_ports {status_led}]
