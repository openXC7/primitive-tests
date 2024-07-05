#!/bin/bash
make PART=xc7a35tfgg484-2 JTAG_CABLE=ft232 BOARD=arty_a7_35t DEBUG_LEDS=1 XDC=davincipro.xdc $@
