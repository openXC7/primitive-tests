`default_nettype none   //do not allow undeclared wires

module iserdes (
    input  wire clk_p,
    input  wire clk_n,
    output wire [7:0] led,
    input  wire button,
    );

    wire clk_ibufg;
    wire clk_in;
    wire clk;
    wire clkx4;

    IBUFDS ibuf_inst (.I(clk_p), .IB(clk_n), .O(clk_ibufg));
    BUFG   bufg_inst (.I(clk_ibufg), .O(clk_in));

    wire clk_fb;
    wire locked;

    PLLE2_ADV #(
      .CLKFBOUT_MULT(1'd1),
      .CLKIN1_PERIOD(5.0),
      .CLKOUT0_DIVIDE(5'd8),
      .CLKOUT0_PHASE(1'd0),
      .CLKOUT1_DIVIDE(7'd32),
      .CLKOUT1_PHASE(1'd0),
      .DIVCLK_DIVIDE(1'd1),
      .REF_JITTER1(0.01),
      .STARTUP_WAIT("FALSE")
    ) PLLE2_ADV (
      .CLKFBIN(clk_fb),
      .CLKIN1(clk_in),
      .PWRDWN(1'b0),
      .RST(1'b0),
      .CLKFBOUT(clk_fb),
      .CLKOUT0(clkx4),
      .CLKOUT1(clk),
      .LOCKED(locked)
    );

    IDELAYCTRL IDELAYCTRL(
      .REFCLK(clk_in),
      .RST(1'b0)
    );

    wire delayed;
    IDELAYE2 #(
      .CINVCTRL_SEL("FALSE"),
      .DELAY_SRC("IDATAIN"),
      .HIGH_PERFORMANCE_MODE("TRUE"),
      .IDELAY_TYPE("VARIABLE"),
      .IDELAY_VALUE(1'd0),
      .PIPE_SEL("FALSE"),
      .REFCLK_FREQUENCY(200.0),
      .SIGNAL_PATTERN("DATA")
    ) IDELAYE2_2 (
      .C(clk),
      .CE(1'b0),
      .IDATAIN(button),
      .INC(1'd1),
      .LD(1'b0),
      .LDPIPEEN(1'd0),
      .DATAOUT(led[0])
    );

    reg [19:0] r_count = 0;

    always @(posedge(clk)) begin
        r_count <= r_count + 1;
    end

    wire clk_slow, clk_slow_4x;
    assign clk_slow = r_count[19];
    assign clk_slow_4x = r_count[17];

endmodule
