module gtx_common (
    input wire clk_p,
    input wire clk_n,
    input wire test_in,
    output wire test_out
);

wire clk_ibufg;
IBUFDS ibuf_inst (.I(clk_p), .IB(clk_n), .O(clk_ibufg));	

wire clkout0, clkout1;
wire gtrefclk0;


BUFG bufg0 (.I(clkout0), .O(gtrefclk0));

wire pll_feedback;
wire locked;

PLLE2_ADV #(
	.CLKFBOUT_MULT(8'd6),
	.CLKIN1_PERIOD(5.0),
	.CLKOUT0_DIVIDE(8'd10),
	.CLKOUT0_PHASE(1'd0),
	.CLKOUT1_DIVIDE(8'd11),
	.CLKOUT1_PHASE(1'd0),
	.DIVCLK_DIVIDE(1'd1),
	.REF_JITTER1(0.01),
	.STARTUP_WAIT("FALSE")
) pll_inst (
	.CLKFBIN(pll_feedback),
	.CLKIN1(clk_ibufg),
	.PWRDWN(1'b0),
	.RST(1'b0),
	.CLKFBOUT(pll_feedback),
	.CLKOUT0(clkout0),
	.CLKOUT1(clkout1),
	.LOCKED(locked)
);

GTXE2_COMMON #(
	.QPLL_FBDIV(3'd5),
	.QPLL_REFCLK_DIV(1'd1)
) GTXE2_COMMON_0 (
	.BGBYPASSB(1'd1),
	.BGMONITORENB(test_in),
	.BGPDB(1'd1),
	.BGRCALOVRD(5'd31),
	.GTREFCLK0(gtrefclk0),
	.GTREFCLK1(),
	.QPLLLOCKEN(1'd1),
	.QPLLPD(1'd0),
	.QPLLREFCLKSEL(1'd1),
	.RCALENB(1'd1),
	.REFCLKOUTMONITOR(test_out)
);

endmodule
