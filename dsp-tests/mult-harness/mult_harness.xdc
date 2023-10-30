create_clock -name clk100 -period 10.000 [get_ports clk]
set_property LOC AA4 [get_ports clk]
set_property IOSTANDARD SSTL15 [get_ports {clk}]

set_property LOC A20 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS18 [get_ports {uart_tx}]

set_property LOC B20 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS18 [get_ports {uart_rx}]
