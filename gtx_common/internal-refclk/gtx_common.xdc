set_property LOC E10 [get_ports clk_p]
set_property IOSTANDARD TMDS_33 [get_ports clk_p]
set_property LOC D10 [get_ports clk_n]
set_property IOSTANDARD TMDS_33 [get_ports clk_n]

set_property LOC D19 [get_ports test_in]
set_property IOSTANDARD LVCMOS33 [get_ports test_in]

set_property LOC D18 [get_ports test_out]
set_property IOSTANDARD LVCMOS33 [get_ports test_out]

#set_property SEVERITY {Warning} [get_drc_checks REQP-56]

