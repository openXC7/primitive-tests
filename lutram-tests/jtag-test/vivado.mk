TOP ?= ${PROJECT}
TOP_MODULE ?= ${TOP}
TOP_SOURCE ?= ${TOP}.v

XDC ?= ${PROJECT}.xdc

VIVADO_SYNTH_OPTS ?=
CREATE_POST_SYNTH_CHECKPOINT ?= #1
CREATE_POST_PLACE_CHECKPOINT ?= #1
CREATE_POST_IMPL_CHECKPOINT ?= #1

# Assumes verilog project
${PROJECT}.vivado.tcl: ${TOP_SOURCE} ${ADDITIONAL_SOURCES} ${XDC}
	echo "# Generated by vivado.mk/Makefile" > $@
	echo "create_project -in_memory -part ${PART}" >> $@
	echo "set_property default_lib xil_defaultlib [current_project]" >> $@
	echo "set_property target_language Verilog [current_project]" >> $@
	echo "read_verilog -library xil_defaultlib ${TOP_SOURCE} ${ADDITIONAL_SOURCES}" >> $@
	echo "read_xdc ${XDC}" >> $@
	echo "synth_design -top ${TOP} -part ${PART} -verilog_define VIVADO ${VIVADO_SYNTH_OPTS}" >> $@
ifneq (${CREATE_POST_SYNTH_CHECKPOINT},)
	echo "write_checkpoint -force ${PROJECT}.synth.dcp" >> $@
endif
	echo "place_design" >> $@
ifneq (${CREATE_POST_PLACE_CHECKPOINT},)
	echo "write_checkpoint -force ${PROJECT}.place.dcp" >> $@
endif
	echo "phys_opt_design" >> $@
	echo "route_design" >> $@
ifneq (${CREATE_POST_IMPL_CHECKPOINT},)
	echo "write_checkpoint -force ${PROJECT}.impl.dcp" >> $@
endif
	echo "write_bitstream -force ${PROJECT}.vivado.bit" >> $@

${PROJECT}.vivado.bit: ${PROJECT}.vivado.tcl
	vivado -mode batch -source $<

.PHONY: vivadoclean
vivadoclean:
	-@rm -f *.vivado.bit
	-@rm -f *.jou
	-@rm -f *.dcp
	-@rm -f *.html
	-@rm -f *.xml
	-@rm -f vivado*.log
	-@rm -f ${PROJECT}.vivado.tcl