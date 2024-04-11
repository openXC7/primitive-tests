#!/usr/bin/env python3
# Copyright (c) 2024 Hans Baier <foss@hans-baier.de>
# SPDX-License-Identifier: BSD-2-Clause

import sys

from migen import *
from litex.gen import *
from litex_boards.platforms import sqrl_acorn
from litex.build.generic_platform import *
from litex.soc.cores.clock import *

from liteiclink.serdes.gtp_7series import GTPQuadPLL, GTP

# IOs ----------------------------------------------------------------------------------------------

_io = [
    ("clkout", 0, Pins("J6"), IOStandard("LVCMOS33")),
        # PCIe.
    ("pcie_tx", 0,
        Subsignal("p", Pins("B6")),
        Subsignal("n", Pins("A6")),
    ),
    ("pcie_rx", 0,
        Subsignal("p", Pins("B10")),
        Subsignal("n", Pins("A10")),
    ),
]

# CRG ----------------------------------------------------------------------------------------------

class CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        self.rst    = Signal()
        self.cd_sys = ClockDomain()

        # Clk/Rst.
        # --------
        clk200 = platform.request("clk200")

        # PLL.
        # ----
        self.pll = pll = S7PLL()
        self.comb += pll.reset.eq(self.rst)
        pll.register_clkin(clk200, 200e6)
        pll.create_clkout(self.cd_sys, sys_clk_freq)

        # GTP RefClk -------------------------------------------------------------------------------
        self.cd_refclk = ClockDomain()
        pll.create_clkout(self.cd_refclk, 125e6)
        platform.add_platform_command("set_property SEVERITY {{Warning}} [get_drc_checks REQP-49]")

        # GTP PLL ----------------------------------------------------------------------------------
        self.gpll = gpll = GTPQuadPLL(self.cd_refclk.clk, 125e6, 0.5e9)
        print(gpll)

        # GTP --------------------------------------------------------------------------------------
        tx_pads = platform.request("pcie_tx")
        rx_pads = platform.request("pcie_rx")
        self.serdes0 = serdes0 = GTP(gpll, tx_pads, rx_pads, sys_clk_freq,
            tx_buffer_enable = True,
            rx_buffer_enable = False,
            clock_aligner    = False,
        )

        self.comb += serdes0.tx_produce_square_wave.eq(1)

        platform.add_period_constraint(serdes0.cd_tx.clk, 1e9/serdes0.tx_clk_freq)
        platform.add_period_constraint(serdes0.cd_rx.clk, 1e9/serdes0.rx_clk_freq)
        platform.add_false_path_constraints(self.cd_sys.clk, serdes0.cd_tx.clk, serdes0.cd_rx.clk)

        counter = Signal(32)
        self.sync.tx += counter.eq(counter + 1)
        self.comb += [
            platform.request("clkout", 0).eq(counter[24]),
            platform.request("user_led", 0).eq(counter[24]),
            platform.request("user_led", 1).eq(gpll.lock),
        ]
        #self.specials += Instance("BUFG", i_I=ClockSignal("gpll"), o_O=platform.request("clkout", 0))

# Build --------------------------------------------------------------------------------------------

def main():
    platform = sqrl_acorn.Platform()
    platform.add_extension(_io)
    crg = CRG(platform, 100e6)
    platform.build(crg)

if __name__ == "__main__":
    main()
