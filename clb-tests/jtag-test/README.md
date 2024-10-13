# LUTRAM Functional Test over JTAG

Development of this test is in progress.

This test is intended to validate functional aspects of LUT_OR_MEM BELs over JTAG.

## Block Diagram

![](./doc/jtag_lutram_block_diagram.png)

## Tasks

- [ ] Add LUTROM primitives
- [ ] Verify shift register carry output port

## Default FPGA Target

By default, this test currently targets Sqrl Acorn CLE215(+) with Digilent HS2 JTAG cable.

## Supporting a New Target

The main requirements are the following:

- 7-series Xilinx FPGA
- JTAG cable (supported by OpenOCD)
- OpenOCD + telnet client 

Because JTAG TCK toggles clock to registers and the LUTRAM under test, there is no need to define
board/pin constraints (unless you want debug LEDs).

To support a new target, update the `FAMILY`/`PART`/`BOARD`/`JTAG_CABLE` variables in the Makefile,
or alternatively run make and override them as in the following example:

```
make FAMILY=kintex7 PART=xc7k325tffg900-2 BOARD=kc705 JTAG_CABLE=digilent ...
```

## Selecting LUTRAM and Generating the Bitstream

### Using Vivado Toolchain

> [!NOTE]
> Append make flag `DEBUG_LEDS=1` to enable optional debug LED status indicators.

To generate the bitstream with a specified LUTRAM cell using the Vivado toolchain, run the following:

```
make [PART=...] [XDC=...] LUTRAM=<LUTRAM_TYPE> vivadoclean top.vivado.bit
```

Available `LUTRAM_TYPE` options:

- Supported by Vivado:
    - LUT5
    - LUT6
    - LUT6_2
    - CFGLUT5
    - SRL16E
    - SRLC16E
    - SRLC32E
    - RAMS32
    - RAMD32
    - RAMS64E
    - RAMD64E
    - RAM32X1S
    - RAM64X1S
    - RAM128X1S
    - RAM256X1S
    - RAM32X1D
    - RAM64X1D
    - RAM128X1D
    - RAM32M
    - RAM64M

### Using OpenXC7 Toolchain

> [!NOTE]
> Append make flag `DEBUG_LEDS=1` to enable optional debug LED status indicators.

To generate the bitstream with a specified LUTRAM cell using the OpenXC7 toolchain, run the following:

```
make [FAMILY=...] [PART=...] [XDC=...] LUTRAM=<LUTRAM_TYPE> clean top.bit
```

Available `LUTRAM_TYPE` options:

- Supported by OpenXC7/NextPNR:
    - SRL16E
    - SRLC32E
    - RAM32X1D
    - RAM64X1D
    - RAM128X1D
    - RAM32M
    - RAM64M
- Not yet supported by OpenXC7/NextPNR:
    - CFGLUT5
    - SRLC16E
    - RAMS32
    - RAMD32
    - RAMS64E
    - RAMD64E
    - RAM32X1S
    - RAM64X1S
    - RAM128X1S
    - RAM256X1S

## Generating 256-bit INIT Pattern

1. Run `generate_init.sh` to generate `lutram_init.vh` and `init.cfg` with a random 256-bit INIT pattern.

2. [Regenerate the bitstream](#SelectingLutramAndGeneratingTheBitstream).

## Programming the Target

> [!NOTE]
> OpenOCD will be used to load the generated bitstream onto the CLE215(+) in place of openFPGALoader.
>
> All other BOARD targets will continue to use openFPGALoader for loading the bitstream.
>
> See the [Makefile](./Makefile) and [openXC7.mk](../../openXC7.mk) for more information.

To load the bitstream built with openXC7 onto the target, run the following:

```
make [BOARD=...] [JTAG_CABLE=...] program
```

To load the bitstream built with vivado onto the target, run the following:

```
make [BOARD=...] [JTAG_CABLE=...] BITSTREAM=top.vivado.bit program
```

## Interactively Test LUTRAM/SRL with OpenOCD

Start OpenOCD session with an interface script (such as [`digilent-hs2.cfg`](./digilent-hs2.cfg))
and [`tests.cfg`](./tests.cfg) loaded:

```
# Load existing interface adapter script from openocd
openocd -f interface/ADAPTER.cfg -f ./tests.cfg
# Local Digilent HS2 interface script
openocd -f ./digilent-hs2.cfg -f ./tests.cfg
```

Access OpenOCD shell via telnet session at localhost port 4444:

```
$ telnet 0.0.0.0 4444
Trying 0.0.0.0...
Escape character is '^]'.
Open On-Chip Debugger
>
```

[`setup.cfg`](./setup.cfg), which is sourced by `tests.cfg`, defines the following commands for reading from or writing to LUTRAM/SRL:

- `read_lutram <address>` : read from LUT(RAM) at `address`; returns data value (in hex) from reply register where each bit in data corresponds to a single LUT output port
    - Note: Assumes shared read (and write) address ports so that all data outputs are captured together for a given address.
    - Tip: Use `bits_mux` helper command defined in `tests.cfg` to filter for a specific port
    - Example: Reading from RAM128X1D (128x1-bit LUTRAM with dual read ports) at address 0x2: `> read_lutram 0x2` returns a 2-bit value in hex
- `read_lutram_range <start> <count>` : read from LUTRAM starting from `start` to `start + count` (exclusive); returns list of data values from reply register
    - Example: Reading all 64 addresses of RAMS64E (64x1-bit LUTRAM with single read port): `> read_lutram_range 0x0 64` returns a list 64 values in hex
- `write_lutram <address> <data>` : write `data` to LUTRAM at `address`, where each bit in data corresponds to a single data input port
    - Example: Writing 1 to RAMS64E at address 40: `> write_lutram 40 1`
- `read_write_srl <n> <data>` : shift in and out n-bit data through SRL starting from most significant bit; returns list of data values from reply register
    - Example: Shift in 16-bit value 0xCAFE into SRL shift register: `> read_write_srl 16 0xCAFE`
    - Tip: Leverage SRL's LUT output port and use `read_lutram_range` to check memory contents after shifting data

[`tests.cfg`](./tests.cfg) defines the following test and helper commands:

- `test_<LUTRAM_TYPE>_init` : compares memory contents of LUT(RAM)/SRL under test against expected INIT pattern(s); returns a list of PASS/FAIL for each LUT output port
    - See comments for each LUT(RAM) INIT test to check expected LUT(RAM) output port connectivity and INIT pattern slice
- `print_test_result <test_result_list>` : prints `lutram_do[<port index>]: <MSG>` for each LUT output port
    - Example: `> print_test_result "PASS FAIL"` prints `lutram_do[0]: PASS` then `lutram_do[1]: FAIL`
    - Example: `> print_test_result [test_RAM32X1D_init]` could print `lutram_do[0]: FAIL` and `lutram_do[1]: FAIL`
- `bit_extract <number> <n>` : returns `n`-th bit of `number`
    - Example: Extracting 0th bit in 0xE: `> bit_extract 0xE 0` returns `0`
    - Example: Extracting 1st bit in 0xE: `> bit_extract 0xE 1` returns `1`
- `bits_mux <samples_list> <n>` : extracts `n`-th bit of each sample in the `samples_list`; returns extracted values as a list
    - Example: `> bits_mux "1 2 4 8 16 32" 0` returns `1 0 0 0 0 0`
    - Example: `> bits_mux "1 2 4 8 16 32" 1` returns `0 1 0 0 0 0`
    - Example: `> bits_mux "1 2 4 8 16 32" 5` returns `0 0 0 0 0 1`
    - Example: `> bits_mux "1 33" 0` returns `1 1`
    - Example: Extracting list of 16 bits obtained from 0th LUT output port: `> bits_mux [read_lutram_range 0x0 16] 0`
- `assemble_from_bit_list <bit_list>` : returns a number constructed from the `bit_list` where n-th bit corresponds to n-th entry in list
    - Example: `> assemble_from_bit_list "1 1 0 1 1 1 1 0"` returns `123`
    - Example: Extracting 16-bit data value obtained from 3rd LUT output port: `assemble_from_bit_list [bits_mux [read_lutram_range 0x0 16] 3]`
- `interleave_bits <n> <num_A> <num_B>` : interleaves two `n`-bit numbers starting with `<num_A>`
    - Example: `> interleave_bits 2 0b11 0b10` returns `13` (0b1101)
    - Example: `> format 0x%x [interleave_bits 8 0b11100011 0b10111110]` returns `0xDEAD`

## Testing LUTRAM INIT with OpenOCD

First build and program FPGA target with LUTRAM to test.

To test if LUTRAM is initialized correctly, run the following:

```
openocd -f interface/ADAPTER.cfg -f ./tests.cfg -c "print_test_result [test_<LUTRAM_TYPE>_init]" -c "shutdown"
```

Available `LUTRAM_TYPE` options:

- LUT5
- LUT6
- LUT6_2
- CFGLUT5
    - ignores shift register carry output CDO
- SRL16E
- SRLC16E
    - ignores shift register carry output Q15
- SRLC32E
    - ignores shift register carry output Q31
- RAMS32
- RAMD32
- RAMS64E
- RAMD64E
- RAM32X1S
- RAM64X1S
- RAM128X1S
- RAM256X1S
- RAM32X1D
- RAM64X1D
- RAM128X1D
- RAM32M
- RAM64M

## License

This work is licensed under [BSD 3-Clause license](../../LICENSE).
