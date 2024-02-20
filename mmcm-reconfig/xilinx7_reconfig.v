
module xilinx7_reconfig (
    input  wire refclk,
    input  wire rst,
    output wire locked,
    output wire outclk_0,

    // CLKOUT0
    input wire [5:0] CLKOUT0_HIGH_TIME,
    input wire [5:0] CLKOUT0_LOW_TIME,
    input wire [2:0] CLKOUT0_PHASE_MUX,
    input wire [2:0] CLKOUT0_FRAC,
    input wire       CLKOUT0_FRAC_EN,
    input wire       CLKOUT0_WF_R,
    input wire       CLKOUT0_EDGE,
    input wire       CLKOUT0_MO_COUNT,
    input wire [5:0] CLKOUT0_DELAY_TIME,

    // CLKFBOUT
    input wire [5:0] CLKFBOUT_HIGH_TIME,
    input wire [5:0] CLKFBOUT_LOW_TIME,
    input wire [2:0] CLKFBOUT_PHASE_MUX,
    input wire [2:0] CLKFBOUT_FRAC,
    input wire       CLKFBOUT_FRAC_EN,
    input wire       CLKFBOUT_WF_R,
    input wire       CLKFBOUT_EDGE,
    input wire       CLKFBOUT_MO_COUNT,
    input wire [5:0] CLKFBOUT_DELAY_TIME,

    // DIVCLK
    input wire [5:0] DIVCLK_HIGH_TIME,
    input wire [5:0] DIVCLK_LOW_TIME,
    input wire       DIVCLK_EDGE,
    input wire       DIVCLK_MO_COUNT,

    // activation
    input  wire start_reconfig,
    output wire reconfig_done
);

    localparam CLKOUT5_REG1  = 7'h06;
    localparam CLKOUT5_REG2  = 7'h07;
    localparam CLKOUT0_REG1  = 7'h08;
    localparam CLKOUT0_REG2  = 7'h09;
    localparam CLKOUT1_REG1  = 7'h0A;
    localparam CLKOUT1_REG2  = 7'h0B;
    localparam CLKOUT2_REG1  = 7'h0C;
    localparam CLKOUT2_REG2  = 7'h0D;
    localparam CLKOUT3_REG1  = 7'h0E;
    localparam CLKOUT3_REG2  = 7'h0F;
    localparam CLKOUT4_REG1  = 7'h10;
    localparam CLKOUT4_REG2  = 7'h11;
    localparam CLKOUT6_REG1  = 7'h12;  // (Not available for PLLE2)
    localparam CLKOUT6_REG2  = 7'h13;  // (Not available for PLLE2)
    localparam CLKFBOUT_REG1 = 7'h14;
    localparam CLKFBOUT_REG2 = 7'h15;
    localparam DIVCLK_REG    = 7'h16;
    localparam LOCK_REG1     = 7'h18;
    localparam LOCK_REG2     = 7'h19;
    localparam LOCK_REG3     = 7'h1A;
    localparam POWER_REG     = 7'h28;
    localparam FILT_REG1     = 7'h4E;
    localparam FILT_REG2     = 7'h4F;

    reg [22:0] mask_rom      [10:0];
    reg [9:0]  filter_lookup [63:0];
    reg [39:0] lock_lookup   [63:0];
    
    localparam POWER_REG_STEP     = 4'd0;
    localparam CLKOUT0_REG1_STEP  = 4'd1;
    localparam CLKOUT0_REG2_STEP  = 4'd2;
    localparam DIVCLK_REG_STEP    = 4'd3;
    localparam CLKFBOUT_REG1_STEP = 4'd4;
    localparam CLKFBOUT_REG2_STEP = 4'd5;
    localparam LOCK_REG1_STEP     = 4'd6;
    localparam LOCK_REG2_STEP     = 4'd7;
    localparam LOCK_REG3_STEP     = 4'd8;
    localparam FILT_REG1_STEP     = 4'd9;
    localparam FILT_REG2_STEP     = 4'd10;
    localparam CONFIG_STEPS       = 4'd11;

initial begin
    mask_rom[POWER_REG_STEP]     = {POWER_REG,     16'h0000};
    mask_rom[CLKOUT0_REG1_STEP]  = {CLKOUT0_REG1,  16'h1000}; // CLKOUT0 [15:0]
    mask_rom[CLKOUT0_REG2_STEP]  = {CLKOUT0_REG2,  16'h8000}; // CLKOUT0 [31:16]
    mask_rom[DIVCLK_REG_STEP]    = {DIVCLK_REG,    16'hC000};
    mask_rom[CLKFBOUT_REG1_STEP] = {CLKFBOUT_REG1, 16'h1000}; // CLKFBOUT [15:0]
    mask_rom[CLKFBOUT_REG2_STEP] = {CLKFBOUT_REG2, 16'h8000}; // CLKFBOUT [31:16]
    mask_rom[LOCK_REG1_STEP]     = {LOCK_REG1,     16'hFC00}; // { LOCK[29:20] }
    mask_rom[LOCK_REG2_STEP]     = {LOCK_REG2,     16'h8000}; // { LOCK[34:30], LOCK[9:0] }
    mask_rom[LOCK_REG3_STEP]     = {LOCK_REG3,     16'h8000}; // { LOCK[39:35], LOCK[19:10] }
    mask_rom[FILT_REG1_STEP]     = {FILT_REG1,     16'h66FF}; // { FILT[9],   2'h0,
                                                              //   FILT[8:7], 2'h0, 
                                                              //   FILT[6],   8'h00 }
    mask_rom[FILT_REG2_STEP]     = {FILT_REG2,     16'h666F}; // { FILT[5],   2'h0, 
                                                              //   FILT[4:3], 2'h0, 
                                                              //   FILT[2:1], 2'h0, 
                                                              //   FILT[0],   4'h0 }

    filter_lookup = {
        // CP_RES_LFHF
        10'b0010_1111_00, // 1
        10'b0100_1111_00, // 2
        10'b0101_1011_00, // 3
        10'b0111_0111_00, // 4
        10'b1101_0111_00, // ....
        10'b1110_1011_00,
        10'b1110_1101_00,
        10'b1111_0011_00,
        10'b1110_0101_00,
        10'b1111_0101_00,
        10'b1111_1001_00,
        10'b1101_0001_00,
        10'b1111_1001_00,
        10'b1111_1001_00,
        10'b1111_1001_00,
        10'b1111_1001_00,
        10'b1111_0101_00,
        10'b1111_0101_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b0101_1100_00,
        10'b0101_1100_00,
        10'b0101_1100_00,
        10'b0101_1100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0011_0100_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0111_0001_00,
        10'b0111_0001_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0110_0001_00,
        10'b0110_0001_00,
        10'b0101_0110_00,
        10'b0101_0110_00,
        10'b0101_0110_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00, // ....
        10'b0010_0100_00, // 61
        10'b0100_1010_00, // 62
        10'b0011_1100_00, // 63
        10'b0011_1100_00  // 64
      };

      lock_lookup = {
        40'b00110_00110_1111101000_1111101001_0000000001,
        40'b00110_00110_1111101000_1111101001_0000000001,
        40'b01000_01000_1111101000_1111101001_0000000001,
        40'b01011_01011_1111101000_1111101001_0000000001,
        40'b01110_01110_1111101000_1111101001_0000000001,
        40'b10001_10001_1111101000_1111101001_0000000001,
        40'b10011_10011_1111101000_1111101001_0000000001,
        40'b10110_10110_1111101000_1111101001_0000000001,
        40'b11001_11001_1111101000_1111101001_0000000001,
        40'b11100_11100_1111101000_1111101001_0000000001,
        40'b11111_11111_1110000100_1111101001_0000000001,
        40'b11111_11111_1100111001_1111101001_0000000001,
        40'b11111_11111_1011101110_1111101001_0000000001,
        40'b11111_11111_1010111100_1111101001_0000000001,
        40'b11111_11111_1010001010_1111101001_0000000001,
        40'b11111_11111_1001110001_1111101001_0000000001,
        40'b11111_11111_1000111111_1111101001_0000000001,
        40'b11111_11111_1000100110_1111101001_0000000001,
        40'b11111_11111_1000001101_1111101001_0000000001,
        40'b11111_11111_0111110100_1111101001_0000000001,
        40'b11111_11111_0111011011_1111101001_0000000001,
        40'b11111_11111_0111000010_1111101001_0000000001,
        40'b11111_11111_0110101001_1111101001_0000000001,
        40'b11111_11111_0110010000_1111101001_0000000001,
        40'b11111_11111_0110010000_1111101001_0000000001,
        40'b11111_11111_0101110111_1111101001_0000000001,
        40'b11111_11111_0101011110_1111101001_0000000001,
        40'b11111_11111_0101011110_1111101001_0000000001,
        40'b11111_11111_0101000101_1111101001_0000000001,
        40'b11111_11111_0101000101_1111101001_0000000001,
        40'b11111_11111_0100101100_1111101001_0000000001,
        40'b11111_11111_0100101100_1111101001_0000000001,
        40'b11111_11111_0100101100_1111101001_0000000001,
        40'b11111_11111_0100010011_1111101001_0000000001,
        40'b11111_11111_0100010011_1111101001_0000000001,
        40'b11111_11111_0100010011_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001,
        40'b11111_11111_0011111010_1111101001_0000000001
      };
end

    wire [15:0]    di;
    wire [6:0]     daddr;
    wire [15:0]    dout;
    wire           den;
    wire           dwe;
    wire           dclk;
    wire           rst_mmcm;
    wire           drdy;

    assign dclk = refclk;

    wire mmcm_feedback;
    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),
        .COMPENSATION("ZHOLD"),
        .CLKFBOUT_MULT_F(20.625),
        .CLKIN1_PERIOD(20.0),
        .CLKOUT0_DIVIDE_F(20.875),
        .CLKOUT0_PHASE(1'd0),
        .DIVCLK_DIVIDE(1'd1),
        .REF_JITTER1(0.01)
    ) MMCME2_ADV (
        .PSINCDEC  (1'b0),
        .CLKFBIN   (mmcm_feedback),
        .CLKIN1    (refclk),
        .PSDONE    (),
        .PSCLK     (1'b0),
        .PSEN      (1'b0),
        .PSINCDEC  (1'b0),
        .PWRDWN    (1'b0),
        .RST       (rst_mmcm),
        .CLKFBOUT  (mmcm_feedback),
        .CLKOUT0   (outclk_0),
        .DO        (dout),
        .DRDY      (drdy),
        .DADDR     (daddr),
        .DCLK      (dclk),
        .DEN       (den),
        .DI        (di),
        .DWE       (dwe),
        .LOCKED    (locked)
    );

    // State machine which communicates with the MMCME reconfiguration bus

    localparam RESTART      = 4'h1;
    localparam WAIT_LOCK    = 4'h2;
    localparam WAIT_START   = 4'h3;
    localparam ADDRESS      = 4'h4;
    localparam WAIT_A_DRDY  = 4'h5;
    localparam BITMASK      = 4'h6;
    localparam BITSET       = 4'h7;
    localparam WRITE        = 4'h8;
    localparam WAIT_DRDY    = 4'h9;

    reg [3:0] current_state = RESTART;
    reg [3:0] next_state    = RESTART;

    // number of configuration steps
    reg  [4:0]  config_step          = 0;
    reg  [4:0]  next_config_step     = 0;
    reg  [4:0]  remaining_steps      = CONFIG_STEPS;
    reg  [4:0]  next_remaining_steps = CONFIG_STEPS;
    reg  [15:0] reg_data = 0;

    wire [7:0]  divclk;
    wire [39:0] lock;
    wire [9:0]  filter;

    assign divclk = DIVCLK_LOW_TIME + DIVCLK_HIGH_TIME - 1;
    assign filter = filter_lookup[divclk];
    assign lock   = lock_lookup[divclk];

    // This block assigns the next register value from the state machine below
    always @(posedge dclk) begin
       daddr       <= next_daddr;
       dwe         <= next_dwe;
       den         <= next_den;
       rst_mmcm    <= next_rst_mmcm;
       di          <= next_di;

       srdy        <= next_srdy;

       config_step     <= next_config_step;
       remaining_steps <= next_remaining_steps;
    end

    // next state with synchroneous reset
    always @(posedge dclk) begin
       if(rst) begin
          current_state <= RESTART;
       end else begin
          current_state <= next_state;
       end
    end

    always @* begin
       next_srdy             = 1'b0;
       next_daddr            = daddr;
       next_dwe              = 1'b0;
       next_den              = 1'b0;
       next_rst_mmcm         = rst_mmcm;
       next_di               = di;
       next_config_step      = config_step;
       next_remaining_steps  = remaining_steps;

       case (config_step)
          POWER_REG_STEP     : reg_data = 16'hffff;
          CLKOUT0_REG1_STEP  : reg_data = { CLKOUT0_PHASE_MUX, 1'b0, CLKOUT0_HIGH_TIME, CLKOUT0_LOW_TIME };
          CLKOUT0_REG2_STEP  : reg_data = { 1'b0, CLKOUT0_FRAC, CLKOUT0_FRAC_EN, CLKOUT0_WF_R, 2'b00, CLKOUT0_EDGE, CLKOUT0_MO_COUNT, CLKOUT0_DELAY_TIME };
          DIVCLK_REG_STEP    : reg_data = { 2'b00, DIVCLK_EDGE, DIVCLK_MO_COUNT, DIVCLK_HIGH_TIME, DIVCLK_LOW_TIME };
          CLKFBOUT_REG1_STEP : reg_data = { CLKFBOUT_PHASE_MUX, 1'b0, CLKFBOUT_HIGH_TIME, CLKFBOUT_LOW_TIME };
          CLKFBOUT_REG2_STEP : reg_data = { 1'b0, CLKFBOUT_FRAC, CLKFBOUT_FRAC_EN, CLKFBOUT_WF_R, 2'b00, CLKFBOUT_EDGE, CLKFBOUT_MO_COUNT, CLKFBOUT_DELAY_TIME };
          LOCK_REG1_STEP     : reg_data = { 6'b000000, lock[29:20] };
          LOCK_REG2_STEP     : reg_data = { 1'b0, lock[34:30], lock[9:0]   };
          LOCK_REG3_STEP     : reg_data = { 1'b0, lock[39:35], lock[19:10] };
          FILT_REG1_STEP     : reg_data = { filter[9], 2'b00, filter[8:7], 2'b00, filter[6], 8'h00 };
          FILT_REG2_STEP     : reg_data = { filter[5], 2'b00, filter[4:3], 2'b00, filter[2:1], 2'b00, filter[0], 4'h0 };
          default            : reg_data = 16'd0;
       endcase

       case (current_state)
          RESTART: begin
             next_daddr        = 7'h00;
             next_di           = 16'h0000;
             next_config_step  = 6'h00;
             next_rst_mmcm     = 1'b1;
             next_state        = WAIT_LOCK;
          end

          // Waits for the MMCM to assert IntLocked - once it does asserts SRDY
          WAIT_LOCK: begin
             // start up the MMCM
             next_rst_mmcm   = 1'b0;
             next_remaining_steps = CONFIG_STEPS;
             next_config_step = 8'h00;

             if(locked) begin
                next_state  = WAIT_START;
                next_srdy   = 1'b1;
             end else begin
                next_state  = WAIT_LOCK;
             end
          end

          WAIT_START: begin
             next_config_step = 8'h00;
             if (start_reconfig) begin
                next_config_step = 8'h00;
                next_state = ADDRESS;
             end else begin
                next_state = WAIT_START;
             end
          end

          // Set the address on the MMCM and assert DEN to read the value
          ADDRESS: begin
             // Reset the DCM through the reconfiguration
             next_rst_mmcm  = 1'b1;
             // read enable
             next_den       = 1'b1;
             // set read address
             next_daddr     = mask_rom[config_step][22:16];
             // Wait for the data to be ready
             next_state     = WAIT_A_DRDY;
          end

          // Wait for DRDY to assert after addressing the MMCM
          WAIT_A_DRDY: begin
             if (drdy) begin
                // Data is ready, next: apply bitmask
                next_state = BITMASK;
             end else begin
                next_state = WAIT_A_DRDY;
             end
          end

          // Zero out the bits that are not set in the mask stored in rom
          BITMASK: begin
             // Mask the data read
             next_di     = mask_rom[config_step][15:0] & dout;
             next_state  = BITSET;
          end

          BITSET: begin
             // Set the bits that need to be assigned
             next_di           = reg_data | di;
             next_config_step  = config_step + 1'b1;
             next_state        = WRITE;
          end

          WRITE: begin
             // write register data
             next_dwe          = 1'b1;
             next_den          = 1'b1;

             next_remaining_steps  = remaining_steps - 1'b1;
             next_state            = WAIT_DRDY;
          end

          WAIT_DRDY: begin
             if(drdy) begin
                // Write is complete
                if(remaining_steps > 0) begin
                   // If there are more registers to write keep going
                   next_state  = ADDRESS;
                end else begin
                   // There are no more registers to write so wait for the MMCM
                   // to lock
                   next_state  = WAIT_LOCK;
                end
             end else begin
                // Keep waiting for write to complete
                next_state     = WAIT_DRDY;
             end
          end

          // If in an unknown state reset the machine
          default: begin
             next_state = RESTART;
          end
       endcase
    end
endmodule