#!/usr/bin/env python3
# Copyright (c) 2024 Hans Baier <foss@hans-baier.de>
# SPDX-License-Identifier: BSD-2-Clause

import sys

from migen import *
from litex.gen import *
from litex_boards.platforms import alientek_davincipro
from litex.build.generic_platform import *
from litex.build.xilinx.vivado import XilinxVivadoToolchain
from litex.soc.cores.clock import *

from liteiclink.serdes.gtp_7series import GTPQuadPLL, GTP
from litex.soc.cores.code_8b10b import K

_io = [
    ("pcie0_tx", 0,
        Subsignal("p", Pins("D7")),
        Subsignal("n", Pins("C7"))
    ),
    ("pcie0_rx", 0,
        Subsignal("p", Pins("D9")),
        Subsignal("n", Pins("C9"))
    ),
]

class TestDesign(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        self.rst    = Signal()
        self.cd_sys = ClockDomain()

        internal_refclk = True

        # Clk/Rst.
        # --------
        clk50 = platform.request("clk50")

        # PLL.
        # ----
        self.pll = pll = S7PLL()
        self.comb += pll.reset.eq(self.rst)
        pll.register_clkin(clk50, 50e6)
        pll.create_clkout(self.cd_sys, sys_clk_freq)

        # GTP RefClk -------------------------------------------------------------------------------
        self.cd_refclk = ClockDomain()
        if internal_refclk:
            pll.create_clkout(self.cd_refclk, 125e6)
            if isinstance(platform.toolchain, XilinxVivadoToolchain):
                platform.add_platform_command("set_property SEVERITY {{Warning}} [get_drc_checks REQP-49]")
        else:
            refclk_pads = platform.request("gtp_refclk")
            self.specials += Instance("IBUFDS_GTE2",
                i_CEB = 0,
                i_I   = refclk_pads.p,
                i_IB  = refclk_pads.n,
                o_O   = ClockSignal("refclk"),
            )

        # GTP PLL ----------------------------------------------------------------------------------
        self.gpll = gpll = GTPQuadPLL(ClockSignal("refclk"), 125e6, 1e9)
        print(gpll)

        # GTP --------------------------------------------------------------------------------------
        tx_pads = platform.request("pcie0_tx")
        rx_pads = platform.request("pcie0_rx")

        self.serdes0 = serdes0 = GTP(gpll, tx_pads, rx_pads, sys_clk_freq,
            tx_buffer_enable = True,
            rx_buffer_enable = False,
            clock_aligner    = False,
        )

        squarewave = False
        loopback = True
        slow_counter = True

        if not squarewave:
            serdes0.add_stream_endpoints()
            serdes0.add_controls()
            serdes0.add_clock_cycles()

        platform.add_period_constraint(serdes0.cd_tx.clk, 1e9/serdes0.tx_clk_freq)
        platform.add_period_constraint(serdes0.cd_rx.clk, 1e9/serdes0.rx_clk_freq)
        platform.add_false_path_constraints(self.cd_sys.clk, serdes0.cd_tx.clk, serdes0.cd_rx.clk)

        counter = Signal(32)
        self.sync.tx += counter.eq(counter + 1)
        if squarewave:
            self.comb += serdes0.tx_produce_square_wave.eq(1),
        else:
            self.comb += [
                serdes0.sink.valid.eq(1),
                serdes0.sink.ctrl.eq(0b1),
                serdes0.sink.data[:8].eq(K(28, 5)),
                serdes0.sink.data[8:].eq(counter[24:32] if slow_counter else counter),
            ]

        leds = Cat([platform.request("user_led", i) for i in range(4)])

        if not loopback:
            self.comb += [
                leds[0].eq(counter[24]),
                leds[1].eq(gpll.lock),
                leds[2].eq(0),
                leds[3].eq(0),
            ]
        else:
            self.comb += [
                serdes0.loopback.eq(0b010),
                serdes0.rx_align.eq(1),
                If(serdes0.source.data[0:8] == K(28, 5),
                    leds.eq(serdes0.source.data[8:]),
                ).Else(
                    leds.eq(serdes0.source.data[0:]),
                ),
                serdes0.source.ready.eq(1),
            ]
        #self.specials += Instance("BUFG", i_I=ClockSignal("tx"), o_O=platform.request("clkout", 0))

# Build --------------------------------------------------------------------------------------------

def main():
    toolchain = "openxc7"
    #toolchain = "vivado"
    platform = alientek_davincipro.Platform(toolchain=toolchain)
    platform.add_extension(_io)
    crg = TestDesign(platform, 100e6)
    platform.build(crg)

if __name__ == "__main__":
    main()
