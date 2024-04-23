# Alientek Davinci Pro Artix7 fgg484 board 
set_property LOC F10  [get_ports refclk_p]
set_property LOC E10  [get_ports refclk_n]

set_property LOC R4 [get_ports {clk}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {clk}]

# pcie_tx:0.p
set_property LOC D7 [get_ports {pcie_tx_p}]

# pcie_tx:0.n
set_property LOC C7 [get_ports {pcie_tx_n}]

# pcie_rx:0.p
set_property LOC D9 [get_ports {pcie_rx_p}]

# pcie_rx:0.n
set_property LOC C9 [get_ports {pcie_rx_n}]

# user_led:0
set_property LOC V9 [get_ports {user_led0}]
set_property IOSTANDARD SSTL135 [get_ports {user_led0}]

# user_led:1
set_property LOC Y8 [get_ports {user_led1}]
set_property IOSTANDARD SSTL135 [get_ports {user_led1}]
