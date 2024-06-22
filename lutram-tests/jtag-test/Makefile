# Target Parameters
FAMILY ?= artix7
PART   ?= xc7a200tfbg484-3
BOARD  ?= acornCle215
ifeq (${BOARD},acornCle215)
XDC    ?= cle215.xdc # supports Debug LEDs
else
XDC    ?= empty.xdc
endif
# See openFPGALoader --list-cables for supported cables
JTAG_CABLE ?= digilent_hs2
JTAG_LINK = -b ${BOARD} -c ${JTAG_CABLE}

# Project Parameters
PROJECT = top
LUTRAM ?= RAM32X1D
YOSYS_OPTS = -DTEST_${LUTRAM}
ifneq (${DEBUG_LEDS},)
YOSYS_OPTS += -DDEBUG_LEDS
endif

CHIPDB ?= ../../chipdb
include ../../openXC7.mk

ifeq (${BOARD},acornCle215)
# openFPGALoader was unable to configure CLE215(+), so using openocd instead...
program: ${PROJECT}.bit
ifeq (${JTAG_CABLE},digilent_hs2)
	openocd -c "adapter driver ftdi" \
		-c "ftdi vid_pid 0x0403 0x6014" \
		-c "ftdi channel 0" \
		-c "reset_config none" \
		-c "ftdi layout_init 0x00e8 0x60eb" \
		-c "source [find cpld/xilinx-xc7.cfg]" \
		-c "adapter speed 4000" \
		-c "init" \
		-c "pld load 0 $<" \
		-c "shutdown"
else
ifeq (${JTAG_CABLE},ft2232)
	# LiteX Acorn Baseboard Mini's onboard FT2232
	openocd -c "adapter driver ftdi" \
		-c "ftdi vid_pid 0x0403 0x6010" \
		-c "ftdi channel 0" \
		-c "reset_config none" \
		-c "ftdi layout_init 0x0808 0x0b0b" \
		-c "source [find cpld/xilinx-xc7.cfg]" \
		-c "adapter speed 4000" \
		-c "init" \
		-c "pld load 0 $<" \
		-c "shutdown"
endif
endif
endif

.PHONY: test
test:
	echo ${YOSYS_OPTS}
