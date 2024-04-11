set_property LOC F6  [get_ports refclk_p_0]
set_property LOC E6  [get_ports refclk_n_0]

set_property LOC J19 [get_ports {clk200_p}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk200_p}]

# clk200:0.n
set_property LOC H19 [get_ports {clk200_n}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk200_n}]

# pcie_tx:0.p
set_property LOC B6 [get_ports {pcie_tx_p}]

# pcie_tx:0.n
set_property LOC A6 [get_ports {pcie_tx_n}]

# pcie_rx:0.p
set_property LOC B10 [get_ports {pcie_rx_p}]

# pcie_rx:0.n
set_property LOC A10 [get_ports {pcie_rx_n}]

# clkout:0
set_property LOC J6 [get_ports {clkout0}]
set_property IOSTANDARD LVCMOS33 [get_ports {clkout0}]

# user_led:0
#set_property LOC G3 [get_ports {user_led0}]
#set_property IOSTANDARD LVCMOS33 [get_ports {user_led0}]

# user_led:1
#set_property LOC H3 [get_ports {user_led1}]
#set_property IOSTANDARD LVCMOS33 [get_ports {user_led1}]

create_clock -name clk200_p -period 5.0 [get_ports clk200_p]

create_clock -name tx_clk -period 40.0 [get_nets tx_clk]

create_clock -name rx_clk -period 40.0 [get_nets rx_clk]