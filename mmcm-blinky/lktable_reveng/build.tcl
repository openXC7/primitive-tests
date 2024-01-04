create_project -in_memory -part __PART__

set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]

read_verilog -library xil_defaultlib blinky.v
read_xdc blinky.xdc

synth_design -top blinky -part __PART__
place_design 
phys_opt_design
route_design
write_checkpoint -force blinky_routed.dcp
write_bitstream -force blinky.bit 
