// Copyright (c) 2024 openXC7
// SPDX-License-Identifier: BSD-3-Clause

// XC7 LUTRAM Functional Test over JTAG

`default_nettype none

`include "lutram_init.vh"
`ifndef LUTRAM_INIT
`define LUTRAM_INIT 256'hDEADBEEF_0150BAD0_CAFEF00D_0F0FFFFF_01234567_89ABCDEF_FEDCBA98_76543210
`endif

// uncomment one of the TEST_* comments to instantiate the LUTRAM for testing
//`define TEST_RAMS32
//`define TEST_RAMD32
//`define TEST_RAMS64E
//`define TEST_RAMD64E
//`define TEST_RAM32X1S
//`define TEST_RAM64X1S
//`define TEST_RAM128X1S
//`define TEST_RAM256X1S
//`define TEST_RAM32X1D
//`define TEST_RAM64X1D
//`define TEST_RAM128X1D
//`define TEST_RAM32M
//`define TEST_RAM64M

// uncomment below to enable Debug LEDs
//`define DEBUG_LEDS

module top (
`ifdef DEBUG_LEDS
    output wire [3:0] led_o
`endif
);
    localparam integer USER_IN_PORT = 3; // Valid options: 1-4
    localparam integer INSTR_OP_WIDTH = 2;
    localparam integer INSTR_ADDR_WIDTH = 8;
    localparam integer INSTR_DATA_WIDTH = 8;
    localparam integer USER_IN_REG_WIDTH = INSTR_OP_WIDTH + INSTR_ADDR_WIDTH + INSTR_DATA_WIDTH;

    localparam integer USER_OUT_PORT = 4; // Valid options: 1-4
    localparam integer USER_OUT_REG_WIDTH = INSTR_ADDR_WIDTH + INSTR_DATA_WIDTH;

    wire [USER_IN_REG_WIDTH-1:0] instr;
    wire [USER_OUT_REG_WIDTH-1:0] reply;

    // Fetch instruction while USER3 instruction is loaded
    frontend #(
        .USER_IN_PORT(USER_IN_PORT),
        .USER_IN_REG_WIDTH(USER_IN_REG_WIDTH)
    ) fe (
        .instr_o(instr)
    );

    // Process instruction and store result while USER4 instruction is loaded
    backend #(
        .INSTR_OP_WIDTH(INSTR_OP_WIDTH),
        .INSTR_ADDR_WIDTH(INSTR_ADDR_WIDTH),
        .INSTR_DATA_WIDTH(INSTR_DATA_WIDTH),
        .USER_IN_REG_WIDTH(USER_IN_REG_WIDTH),
        .USER_OUT_PORT(USER_OUT_PORT),
        .USER_OUT_REG_WIDTH(USER_OUT_REG_WIDTH)
    ) be (
        .instr_i(instr),
        .reply_o(reply)
    );

`ifdef DEBUG_LEDS
    // assuming active-low LEDs
    assign led_o[2:0] = ~instr[INSTR_OP_WIDTH +: 3];
    assign led_o[3] = ~reply[INSTR_ADDR_WIDTH];
`endif

endmodule

module frontend #(
    parameter integer USER_IN_PORT = 3,
    parameter integer USER_IN_REG_WIDTH = 2 // >= 2
) (
    output reg [USER_IN_REG_WIDTH-1:0] instr_o = {USER_IN_REG_WIDTH{1'b0}}
);
    
    wire jtag_drck;
    wire jtag_shift;
    wire jtag_tdi;
    wire jtag_tdo;

    BSCANE2 #(
        .JTAG_CHAIN(USER_IN_PORT)
    ) bscan_in (
        .DRCK(jtag_drck),
        .SHIFT(jtag_shift),
        .TDI(jtag_tdi),
        .TDO(jtag_tdo)
    );

    assign jtag_tdo = 1'b1;

    always @(posedge jtag_drck) begin
        if (jtag_shift) begin
            // Fetch instruction starting with LSB
            instr_o <= {jtag_tdi,instr_o[USER_IN_REG_WIDTH-1:1]};
        end
    end

endmodule

module backend #(
    parameter [255:0] INIT = `LUTRAM_INIT,
    parameter integer INSTR_OP_WIDTH = 2,
    parameter integer INSTR_ADDR_WIDTH = 8,
    parameter integer INSTR_DATA_WIDTH = 8,
    parameter integer USER_IN_REG_WIDTH = INSTR_OP_WIDTH + INSTR_ADDR_WIDTH + INSTR_DATA_WIDTH,
    parameter integer USER_OUT_PORT = 4, // Valid options: 1-4
    parameter integer USER_OUT_REG_WIDTH = INSTR_ADDR_WIDTH + INSTR_DATA_WIDTH
) (
    input wire [USER_IN_REG_WIDTH-1:0] instr_i,
    output reg [USER_OUT_REG_WIDTH-1:0] reply_o = {USER_OUT_REG_WIDTH{1'b0}}
);

    wire jtag_drck;
    wire jtag_capture;
    wire jtag_shift;
    wire jtag_tdo;

    wire lutram_we;
    wire [INSTR_ADDR_WIDTH-1:0] lutram_addr;
    wire [INSTR_DATA_WIDTH-1:0] lutram_di;
    wire [INSTR_DATA_WIDTH-1:0] lutram_do;

    assign lutram_we = instr_i[0 +: INSTR_OP_WIDTH] == 2'b11;
    assign lutram_addr = instr_i[INSTR_OP_WIDTH +: INSTR_ADDR_WIDTH];
    assign lutram_di = instr_i[INSTR_OP_WIDTH + INSTR_ADDR_WIDTH +: INSTR_DATA_WIDTH];

    // Instantiate LUTRAM with:
    // - each INIT parameter in the LUTRAM set with non-overlapping slices of
    //   this module's 256-bit INIT parameter.
    // - jtag_drck toggling LUTRAM WCLK
    // - lutram_we connected to LUTRAM WE
    // - every LUTRAM address input accessing the same address (lutram_addr)
    //     - leave unused lutram_addr[n] nets unconnected
    // - every LUTRAM data input mapped to non-overlapping bit slices of lutram_di
    //     - leave unused lutram_di[n] nets unconnected
    // - every LUTRAM data output mapped to non-overlapping bit slices of lutram_do
    //     - tie unused lutram_do[n] nets low
`include "lutram_inst.vh"

    BSCANE2 #(
        .JTAG_CHAIN(USER_OUT_PORT)
    ) bscan_out (
        .DRCK(jtag_drck),
        .CAPTURE(jtag_capture),
        .SHIFT(jtag_shift),
        .TDO(jtag_tdo)
    );

    // Shift reply out starting with LSB
    assign jtag_tdo = reply_o[0];

    always @(posedge jtag_drck) begin
        if (jtag_capture) begin
            reply_o <= {lutram_do,instr_i[INSTR_OP_WIDTH +: INSTR_ADDR_WIDTH]};
        end
        else if (jtag_shift) begin
            reply_o <= {reply_o[0],reply_o[USER_OUT_REG_WIDTH-1:1]};
        end
    end

endmodule
