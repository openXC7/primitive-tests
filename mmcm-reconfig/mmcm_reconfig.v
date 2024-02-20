`default_nettype none   //do not allow undeclared wires

module mmcm_reconfig (
    input  wire       clk,
    output wire [1:0] led,
    output wire       clkout
    );

    wire pll_feedback;
    wire pll_clk;
    wire mmcm_clk;

    PLLE2_ADV #(
        .CLKFBOUT_MULT(8'd20),
        .CLKIN1_PERIOD(20.0),
        .CLKOUT0_DIVIDE(8'd20),
        .CLKOUT0_PHASE(1'd0),
        .DIVCLK_DIVIDE(1'd1),
        .REF_JITTER1(0.01),
        .STARTUP_WAIT("FALSE")
    ) PLLE2_ADV (
        .CLKFBIN(pll_feedback),
        .CLKIN1(clk),
        .PWRDWN(1'b0),
        .RST(1'b0),
        .CLKFBOUT(pll_feedback),
        .CLKOUT0(pll_clk),
        .LOCKED()
    );

    xilinx7_reconfig reconfig (
        .refclk(clk),
        .rst(1'b0),
        .outclk_0(mmcm_clk),
        .locked()
    );

    assign clkout = mmcm_clk;

    reg [24:0] count = 0;
    always @(posedge(pll_clk)) count <= count + 1;
    assign led[0] = count[24];

    reg [24:0] r_count = 0;
    always @(posedge(mmcm_clk)) r_count <= r_count + 1;
    assign led[1] = r_count[24];

endmodule
