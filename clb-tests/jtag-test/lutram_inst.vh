// Instantiate LUTRAM
`ifdef TEST_RAMS32
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAMS32 #(
        .IS_CLK_INVERTED(1'b0),
        .INIT(INIT[31:0])
    ) rams32 (
        .CLK(jtag_drck),
        .WE(lutram_we),
        .I(lutram_di[0]),
        .O(lutram_do[0]),
        .ADR4(lutram_addr[4]),
        .ADR3(lutram_addr[3]),
        .ADR2(lutram_addr[2]),
        .ADR1(lutram_addr[1]),
        .ADR0(lutram_addr[0])
    );
`elsif TEST_RAMD32
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAMD32 #(
        .IS_CLK_INVERTED(1'b0),
        .INIT(INIT[31:0])
    ) ramd32 (
        .CLK(jtag_drck),
        .WE(lutram_we),
        .I(lutram_di[0]),
        .O(lutram_do[0]),
        .WADR4(lutram_addr[4]),
        .WADR3(lutram_addr[3]),
        .WADR2(lutram_addr[2]),
        .WADR1(lutram_addr[1]),
        .WADR0(lutram_addr[0]),
        .RADR4(lutram_addr[4]),
        .RADR3(lutram_addr[3]),
        .RADR2(lutram_addr[2]),
        .RADR1(lutram_addr[1]),
        .RADR0(lutram_addr[0])
    );
`elsif TEST_RAMS64E
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAMS64E #(
        .IS_CLK_INVERTED(1'b0),
        .INIT(INIT[63:0])
    ) rams64e (
        .CLK(jtag_drck),
        .WE(lutram_we),
        .I(lutram_di[0]),
        .O(lutram_do[0]),
        .WADR7(lutram_addr[7]),
        .WADR6(lutram_addr[6]),
        .WADR5(lutram_addr[5]),
        .WADR4(lutram_addr[4]),
        .WADR3(lutram_addr[3]),
        .WADR2(lutram_addr[2]),
        .WADR1(lutram_addr[1]),
        .WADR0(lutram_addr[0]),
        .RADR5(lutram_addr[5]),
        .RADR4(lutram_addr[4]),
        .RADR3(lutram_addr[3]),
        .RADR2(lutram_addr[2]),
        .RADR1(lutram_addr[1]),
        .RADR0(lutram_addr[0])
    );
`elsif TEST_RAMD64E
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAMD64E #(
        .IS_CLK_INVERTED(1'b0),
        .INIT(INIT[63:0])
    ) ramd64e (
        .CLK(jtag_drck),
        .WE(lutram_we),
        .I(lutram_di[0]),
        .O(lutram_do[0]),
        .WADR4(lutram_addr[4]),
        .WADR3(lutram_addr[3]),
        .WADR2(lutram_addr[2]),
        .WADR1(lutram_addr[1]),
        .WADR0(lutram_addr[0]),
        .RADR4(lutram_addr[4]),
        .RADR3(lutram_addr[3]),
        .RADR2(lutram_addr[2]),
        .RADR1(lutram_addr[1]),
        .RADR0(lutram_addr[0])
    );
`elsif TEST_RAM32X1S
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM32X1S #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT(INIT[31:0])
    ) ram32x1s (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .D(lutram_di[0]),
        .O(lutram_do[0]),
        .A4(lutram_addr[4]),
        .A3(lutram_addr[3]),
        .A2(lutram_addr[2]),
        .A1(lutram_addr[1]),
        .A0(lutram_addr[0])
    );
`elsif TEST_RAM64X1S
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM64X1S #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT(INIT[63:0])
    ) ram64x1s (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .D(lutram_di[0]),
        .O(lutram_do[0]),
        .A5(lutram_addr[5]),
        .A4(lutram_addr[4]),
        .A3(lutram_addr[3]),
        .A2(lutram_addr[2]),
        .A1(lutram_addr[1]),
        .A0(lutram_addr[0])
    );
`elsif TEST_RAM128X1S
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM128X1S #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT(INIT[127:0])
    ) ram128x1s (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .D(lutram_di[0]),
        .O(lutram_do[0]),
        .A6(lutram_addr[6]),
        .A5(lutram_addr[5]),
        .A4(lutram_addr[4]),
        .A3(lutram_addr[3]),
        .A2(lutram_addr[2]),
        .A1(lutram_addr[1]),
        .A0(lutram_addr[0])
    );
`elsif TEST_RAM256X1S
    localparam integer NUM_OUTPUT = 1;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM256X1S #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT(INIT[255:0])
    ) ram256x1s (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .D(lutram_di[0]),
        .O(lutram_do[0]),
        .A(lutram_addr[7:0])
    );
`elsif TEST_RAM32X1D
    localparam integer NUM_OUTPUT = 2;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM32X1D #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT(INIT[31:0])
    ) ram32x1d (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .D(lutram_di[0]),
        .SPO(lutram_do[0]),
        .DPO(lutram_do[1]),
        .A4(lutram_addr[4]),
        .A3(lutram_addr[3]),
        .A2(lutram_addr[2]),
        .A1(lutram_addr[1]),
        .A0(lutram_addr[0]),
        .DPRA4(lutram_addr[4]),
        .DPRA3(lutram_addr[3]),
        .DPRA2(lutram_addr[2]),
        .DPRA1(lutram_addr[1]),
        .DPRA0(lutram_addr[0])
    );
`elsif TEST_RAM64X1D
    localparam integer NUM_OUTPUT = 2;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM64X1D #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT(INIT[63:0])
    ) ram64x1d (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .D(lutram_di[0]),
        .SPO(lutram_do[0]),
        .DPO(lutram_do[1]),
        .A5(lutram_addr[5]),
        .A4(lutram_addr[4]),
        .A3(lutram_addr[3]),
        .A2(lutram_addr[2]),
        .A1(lutram_addr[1]),
        .A0(lutram_addr[0]),
        .DPRA5(lutram_addr[5]),
        .DPRA4(lutram_addr[4]),
        .DPRA3(lutram_addr[3]),
        .DPRA2(lutram_addr[2]),
        .DPRA1(lutram_addr[1]),
        .DPRA0(lutram_addr[0])
    );
`elsif TEST_RAM128X1D
    localparam integer NUM_OUTPUT = 2;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM128X1D #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT(INIT[127:0])
    ) ram128x1d (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .D(lutram_di[0]),
        .SPO(lutram_do[0]),
        .DPO(lutram_do[1]),
        .A(lutram_addr[6:0]),
        .DPRA(lutram_addr[6:0])
    );
`elsif TEST_RAM32M
    localparam integer NUM_OUTPUT = 8;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM32M #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT_D(INIT[63:0]),
        .INIT_C(INIT[127:64]),
        .INIT_B(INIT[191:128]),
        .INIT_A(INIT[255:192])
    ) ram32m (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .DID(lutram_di[1:0]),
        .DIC(lutram_di[3:2]),
        .DIB(lutram_di[5:4]),
        .DIA(lutram_di[7:6]),
        .DOD(lutram_do[1:0]),
        .DOC(lutram_do[3:2]),
        .DOB(lutram_do[5:4]),
        .DOA(lutram_do[7:6]),
        .ADDRD(lutram_addr[4:0]),
        .ADDRC(lutram_addr[4:0]),
        .ADDRB(lutram_addr[4:0]),
        .ADDRA(lutram_addr[4:0])
    );
`elsif TEST_RAM64M
    localparam integer NUM_OUTPUT = 4;
`ifdef YOSYS
    (* keep *)
`elsif VIVADO
    (* KEEP, DONT_TOUCH *)
`endif
    RAM64M #(
        .IS_WCLK_INVERTED(1'b0),
        .INIT_D(INIT[63:0]),
        .INIT_C(INIT[127:64]),
        .INIT_B(INIT[191:128]),
        .INIT_A(INIT[255:192])
    ) ram64m (
        .WCLK(jtag_drck),
        .WE(lutram_we),
        .DID(lutram_di[0]),
        .DIC(lutram_di[1]),
        .DIB(lutram_di[2]),
        .DIA(lutram_di[3]),
        .DOD(lutram_do[0]),
        .DOC(lutram_do[1]),
        .DOB(lutram_do[2]),
        .DOA(lutram_do[3]),
        .ADDRD(lutram_addr[5:0]),
        .ADDRC(lutram_addr[5:0]),
        .ADDRB(lutram_addr[5:0]),
        .ADDRA(lutram_addr[5:0])
    );
`else
    localparam integer NUM_OUTPUT = 0;
`endif

generate if (NUM_OUTPUT < INSTR_DATA_WIDTH)
    // Assign unused lutram_do nets to 0
    assign lutram_do[NUM_OUTPUT +: INSTR_DATA_WIDTH-NUM_OUTPUT] = {(INSTR_DATA_WIDTH-NUM_OUTPUT){1'b0}};
endgenerate
