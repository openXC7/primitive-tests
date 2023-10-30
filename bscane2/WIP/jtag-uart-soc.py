#!/usr/bin/env python3

#
# This file is part of LiteX-Boards.
#
# Copyright (c) 2021 Hans Baier <hansfbaier@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

# https://www.aliexpress.com/item/4000170003461.html

from migen import *

from litex.gen import *

from litex_boards.platforms import qmtech_artix7_fgg676

from litex.soc.cores.clock import *
from litex.soc.integration.soc import SoCRegion
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.video import VideoVGAPHY
from litex.soc.cores.led import LedChaser

from litedram.modules import MT41J128M16
from litedram.phy import s7ddrphy

from liteeth.phy.mii import LiteEthPHYMII

# CRG ----------------------------------------------------------------------------------------------

class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        self.rst          = Signal()
        self.cd_sys       = ClockDomain()

        self.pll = pll = S7PLL(speedgrade=-1)
        try:
            reset_button = platform.request("cpu_reset")
            self.comb += pll.reset.eq(~reset_button | self.rst)
        except:
            self.comb += pll.reset.eq(self.rst)

        pll.register_clkin(platform.request("clk50"), 50e6)
        pll.create_clkout(self.cd_sys,       sys_clk_freq)

        platform.add_false_path_constraints(self.cd_sys.clk, pll.clkin) # Ignore sys_clk to pll.clkin path created by SoC's rst.

# BaseSoC ------------------------------------------------------------------------------------------

class BaseSoC(SoCCore):
    def __init__(self, toolchain="vivado", kgates=100, sys_clk_freq=100e6, with_daughterboard=False,
        with_led_chaser        = True,
        with_jtagbone          = True,
        **kwargs):
        platform = qmtech_artix7_fgg676.Platform(kgates=kgates, toolchain=toolchain, with_daughterboard=with_daughterboard)

        # CRG --------------------------------------------------------------------------------------
        self.crg = _CRG(platform, sys_clk_freq)

        # SoCCore ----------------------------------------------------------------------------------
        kwargs["cpu"]       = "femtorv32"
        kwargs["uart_name"] = "jtag_uart"
        SoCCore.__init__(self, platform, sys_clk_freq,
            ident = f"LiteX SoC on QMTech XC7A{kgates}T" + (" + Daughterboard" if with_daughterboard else ""),
            **kwargs)

        # Leds -------------------------------------------------------------------------------------
        if with_led_chaser:
            self.leds = LedChaser(
                pads         = platform.request_all("user_led"),
                sys_clk_freq = sys_clk_freq)


# Build --------------------------------------------------------------------------------------------

def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(platform=qmtech_artix7_fgg676.Platform, description="LiteX SoC on QMTech XC7AXXXT.")
    parser.add_target_argument("--kgates",              default=100,   type=int,  help="Number of kgates. Allowed values: 75, 100, 200, representing XC7A75T, XC7A100T and XC7A200T")
    parser.add_target_argument("--sys-clk-freq",        default=100e6, type=float,  help="System clock frequency.")
    args = parser.parse_args()

    soc = BaseSoC(
        toolchain              = args.toolchain,
        kgates                 = args.kgates,
        sys_clk_freq           = args.sys_clk_freq,
        with_daughterboard     = True,
        with_jtagbone          = True,
        **parser.soc_argdict
    )

    builder = Builder(soc, **parser.builder_argdict)
    if args.build:
        builder.build(**parser.toolchain_argdict)

    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream(builder.get_bitstream_filename(mode="sram"))

if __name__ == "__main__":
    main()
