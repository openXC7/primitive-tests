`default_nettype none   //do not allow undeclared wires

module blinky (
    input  wire clk,
    output wire led,
    output wire [2:0] clkout
    );

    wire pll_clk;
    wire feedback;

    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT_F(20.250),
        .CLKIN1_PERIOD(20.0),
        .CLKOUT0_DIVIDE_F(20.125),
        .CLKOUT0_PHASE(1'd0),
        .CLKOUT1_DIVIDE(8'd21),
        .CLKOUT1_PHASE(1'd0),
        .CLKOUT2_DIVIDE(8'd22),
        .CLKOUT2_PHASE(1'd0),
        .CLKOUT3_DIVIDE(8'd23),
        .CLKOUT3_PHASE(1'd0),
        .DIVCLK_DIVIDE(1'd1),
        .REF_JITTER1(0.01)
    ) MMCME2_ADV (
        .CLKFBIN(feedback),
        .CLKIN1(clk),
        .PWRDWN(1'b0),
        .RST(1'b0),
        .CLKFBOUT(feedback),
        .CLKOUT0(pll_clk),
        .CLKOUT1(clkout[0]),
        .CLKOUT2(clkout[1]),
        .CLKOUT3(clkout[2]),
        .LOCKED()
    );

    reg [24:0] r_count = 0;

    always @(posedge(pll_clk)) r_count <= r_count + 1;

    assign led = r_count[24];
endmodule
