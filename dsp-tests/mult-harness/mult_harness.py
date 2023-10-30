#!/usr/bin/env python3

from amaranth         import Elaboratable, Module, Signal, Array, Cat, Mux
from amaranth.hdl.ast import Fell
from amaranth.hdl     import ir
from amaranth.back import verilog, rtlil

from amlib.io.serial import AsyncSerial, AsyncSerialTX


class Multiplier(Elaboratable):
    def __init__(self, bitwidth) -> None:
        self.factor_a = Signal(bitwidth)
        self.factor_b = Signal(bitwidth)
        self.result   = Signal(2 * bitwidth)

    def elaborate(self, platform):
        m = Module()

        m.d.sync += self.result.eq(self.factor_a * self.factor_b)

        return m

class TimesTable(Elaboratable):
    def __init__(self) -> None:
        self.tx = Signal()

    def elaborate(self, platform):
        m = Module()

        clk_freq = int(100e6)
        divisor = int(clk_freq // 115200)
        print(f"using serial divisor: {divisor} with baudrate {clk_freq // divisor}")
        m.submodules.serial = serial = AsyncSerialTX(divisor=divisor)

        m.submodules.mult = mult = Multiplier(bitwidth=96)

        a = Signal.like(mult.factor_a)
        b = Signal.like(mult.factor_b)
        r = Signal.like(mult.result)

        m.d.comb += [
            mult.factor_a.eq(a << 40),
            mult.factor_b.eq(b << 40),
            r.eq(mult.result >> 80),
            self.tx.eq(serial.o),
        ]

        max_n = 512
        with m.If(serial.rdy):
            m.d.comb += [
                serial.data.eq(
                    Mux(r <= 0xff,     r,
                    Mux(r <= 0xffff,   r[8:],
                    Mux(r <= 0xffffff, r[16:], r)))),
                serial.ack.eq(1),
            ]
            m.d.sync += a.eq(a + 1)
            with m.If(a == max_n):
                m.d.sync += [
                    a.eq(0),
                    b.eq(b + 1),
                ]
                with m.If(b == max_n):
                    m.d.sync += b.eq(0)

        return m

class MultHarness(Elaboratable):
    def __init__(self, name="multi_harness", bitwidth=16) -> None:
        self.tx = Signal()
        self.rx = Signal()
        self.bitwidth = bitwidth

    def elaborate(self, platform):
        m = Module()
        no_argbytes = self.bitwidth // 8
        last_argbyte = no_argbytes - 1

        divisor = 100e6 // 115200
        print(f"using serial divisor: {divisor} with baudrate {divisor * 100e6}")
        m.submodules.serial = serial = AsyncSerial(divisor=divisor)
        m.d.comb += [
            self.tx.eq(serial.tx.o),
            self.rx.eq(serial.rx.i),
        ]

        m.submodules.mult = mult = Multiplier(self.bitwidth)

        a = Array([Signal(8) for i in range(no_argbytes)])
        b = Array([Signal(8) for i in range(no_argbytes)])
        r = Signal(Array([Signal(8) for i in range(2 * no_argbytes)]))

        argno   = Signal()
        argbyte = Signal(range(no_argbytes))

        m.d.comb += [
            mult.factor_a.eq(Cat(a)),
            mult.factor_b.eq(Cat(b)),
            Cat(r).eq(mult.result),
        ]

        with m.If(serial.rx.rdy):
            m.d.sync += [
                a[argbyte].eq(serial.rx.data),
                argbyte.eq(argbyte + 1)
            ]
            with m.If(argbyte == last_argbyte):
                m.d.sync += argno.eq(argno + 1)

        result_ready = Signal()
        resultbyte = Signal(range(2 * no_argbytes))
        with m.If(Fell(argno)):
            m.d.sync += result_ready.eq(1)

        with m.If(result_ready & serial.tx.rdy):
            m.d.comb += [
                serial.tx.data.eq(r[resultbyte]),
                serial.tx.ack.eq(1),
            ]
            m.d.sync += resultbyte.eq(resultbyte + 1)

        return m

if __name__ == "__main__":
    m = TimesTable()
    fragment = ir.Fragment.get(m, None).prepare(ports=[m.tx])
    il_text, name_map = rtlil.convert_fragment(fragment, name="TimesTable", emit_src=False)
    print(str(name_map))

    with open(f"mult_harness.rtlil", 'w') as f:
        f.write(il_text)