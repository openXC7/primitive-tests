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
from litex.soc.cores.jtag import JTAGPHY, XilinxJTAG

class BaseSoC(Module):
    def __init__(self, platform):
        sys_clk_freq = 100e6
        self.clock_domains.cd_sys = ClockDomain()
        self.comb += ClockSignal().eq(platform.request("clk50"))

        leds = platform.request_all("user_led")
        self.submodules.jtag = jtag = JTAGPHY(device=platform.device, data_width=len(leds))

        self.sync += If(jtag.source.valid, leds.eq(jtag.source.data))
        self.comb += [
            jtag.source.ready.eq(1),
            jtag.sink.data.eq(leds),
            jtag.sink.valid.eq(1)
        ]

# Build --------------------------------------------------------------------------------------------

def main():
    #toolchain = "vivado"
    toolchain = "openxc7"
    platform = qmtech_artix7_fgg676.Platform(kgates=100, toolchain=toolchain, with_daughterboard=True)
    soc = BaseSoC(platform)
    platform.build(soc)

if __name__ == "__main__":
    main()
