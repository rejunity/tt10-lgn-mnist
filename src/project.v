/*
 * Copyright (c) 2024 Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

 `default_nettype none

 module tt_um_rejunity_lgn_mnist (
     input  wire [7:0] ui_in,    // Dedicated inputs
     output wire [7:0] uo_out,   // Dedicated outputs
     input  wire [7:0] uio_in,   // IOs: Input path
     output wire [7:0] uio_out,  // IOs: Output path
     output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
     input  wire       ena,      // always 1 when the design is powered, so you can ignore it
     input  wire       clk,      // clock
     input  wire       rst_n     // reset_n - low to reset
 );
 
   assign uio_oe  = 8'b0111_1111; // BIDIR in output mode, except "write_enable" the highest bit 
   wire write_enable = 1; // ~uio_in[7];
 
   // List all unused inputs to prevent warnings
   wire _unused = &{ena, rst_n, 1'b0};
 
   localparam INPUTS  = 256;
   localparam OUTPUTS = 4000;
   localparam CATEGORIES = 10;
   localparam BITS_PER_CATEGORY = 255;
   localparam BITS_PER_CATEGORY_SUM = $clog2(BITS_PER_CATEGORY);

   reg pattern [0:15][0:15];
   initial begin
    // Number ['0'][1]
       pattern[0][0] = 0;  pattern[0][1] = 0;  pattern[0][2] = 0;  pattern[0][3] = 0;  pattern[0][4] = 0;  pattern[0][5] = 0;  pattern[0][6] = 0;  pattern[0][7] = 0;  pattern[0][8] = 0;  pattern[0][9] = 0;  pattern[0][10] = 0;  pattern[0][11] = 0;  pattern[0][12] = 0;  pattern[0][13] = 0;  pattern[0][14] = 0;  pattern[0][15] = 0;
       pattern[1][0] = 0;  pattern[1][1] = 0;  pattern[1][2] = 0;  pattern[1][3] = 0;  pattern[1][4] = 0;  pattern[1][5] = 0;  pattern[1][6] = 0;  pattern[1][7] = 0;  pattern[1][8] = 0;  pattern[1][9] = 0;  pattern[1][10] = 0;  pattern[1][11] = 0;  pattern[1][12] = 0;  pattern[1][13] = 0;  pattern[1][14] = 0;  pattern[1][15] = 0;
       pattern[2][0] = 0;  pattern[2][1] = 0;  pattern[2][2] = 0;  pattern[2][3] = 0;  pattern[2][4] = 0;  pattern[2][5] = 0;  pattern[2][6] = 1;  pattern[2][7] = 1;  pattern[2][8] = 1;  pattern[2][9] = 1;  pattern[2][10] = 1;  pattern[2][11] = 0;  pattern[2][12] = 0;  pattern[2][13] = 0;  pattern[2][14] = 0;  pattern[2][15] = 0;
       pattern[3][0] = 0;  pattern[3][1] = 0;  pattern[3][2] = 0;  pattern[3][3] = 0;  pattern[3][4] = 0;  pattern[3][5] = 1;  pattern[3][6] = 1;  pattern[3][7] = 1;  pattern[3][8] = 1;  pattern[3][9] = 1;  pattern[3][10] = 1;  pattern[3][11] = 1;  pattern[3][12] = 0;  pattern[3][13] = 0;  pattern[3][14] = 0;  pattern[3][15] = 0;
       pattern[4][0] = 0;  pattern[4][1] = 0;  pattern[4][2] = 0;  pattern[4][3] = 0;  pattern[4][4] = 0;  pattern[4][5] = 1;  pattern[4][6] = 1;  pattern[4][7] = 1;  pattern[4][8] = 0;  pattern[4][9] = 0;  pattern[4][10] = 1;  pattern[4][11] = 1;  pattern[4][12] = 1;  pattern[4][13] = 0;  pattern[4][14] = 0;  pattern[4][15] = 0;
       pattern[5][0] = 0;  pattern[5][1] = 0;  pattern[5][2] = 0;  pattern[5][3] = 0;  pattern[5][4] = 1;  pattern[5][5] = 1;  pattern[5][6] = 1;  pattern[5][7] = 0;  pattern[5][8] = 0;  pattern[5][9] = 0;  pattern[5][10] = 0;  pattern[5][11] = 1;  pattern[5][12] = 1;  pattern[5][13] = 0;  pattern[5][14] = 0;  pattern[5][15] = 0;
       pattern[6][0] = 0;  pattern[6][1] = 0;  pattern[6][2] = 0;  pattern[6][3] = 0;  pattern[6][4] = 1;  pattern[6][5] = 1;  pattern[6][6] = 0;  pattern[6][7] = 0;  pattern[6][8] = 0;  pattern[6][9] = 0;  pattern[6][10] = 0;  pattern[6][11] = 1;  pattern[6][12] = 1;  pattern[6][13] = 0;  pattern[6][14] = 0;  pattern[6][15] = 0;
       pattern[7][0] = 0;  pattern[7][1] = 0;  pattern[7][2] = 0;  pattern[7][3] = 0;  pattern[7][4] = 1;  pattern[7][5] = 1;  pattern[7][6] = 0;  pattern[7][7] = 0;  pattern[7][8] = 0;  pattern[7][9] = 0;  pattern[7][10] = 0;  pattern[7][11] = 1;  pattern[7][12] = 1;  pattern[7][13] = 0;  pattern[7][14] = 0;  pattern[7][15] = 0;
       pattern[8][0] = 0;  pattern[8][1] = 0;  pattern[8][2] = 0;  pattern[8][3] = 0;  pattern[8][4] = 1;  pattern[8][5] = 1;  pattern[8][6] = 0;  pattern[8][7] = 0;  pattern[8][8] = 0;  pattern[8][9] = 0;  pattern[8][10] = 0;  pattern[8][11] = 1;  pattern[8][12] = 1;  pattern[8][13] = 0;  pattern[8][14] = 0;  pattern[8][15] = 0;
       pattern[9][0] = 0;  pattern[9][1] = 0;  pattern[9][2] = 0;  pattern[9][3] = 1;  pattern[9][4] = 1;  pattern[9][5] = 0;  pattern[9][6] = 0;  pattern[9][7] = 0;  pattern[9][8] = 0;  pattern[9][9] = 0;  pattern[9][10] = 0;  pattern[9][11] = 1;  pattern[9][12] = 1;  pattern[9][13] = 0;  pattern[9][14] = 0;  pattern[9][15] = 0;
       pattern[10][0] = 0;  pattern[10][1] = 0;  pattern[10][2] = 0;  pattern[10][3] = 1;  pattern[10][4] = 1;  pattern[10][5] = 0;  pattern[10][6] = 0;  pattern[10][7] = 0;  pattern[10][8] = 0;  pattern[10][9] = 0;  pattern[10][10] = 1;  pattern[10][11] = 1;  pattern[10][12] = 1;  pattern[10][13] = 0;  pattern[10][14] = 0;  pattern[10][15] = 0;
       pattern[11][0] = 0;  pattern[11][1] = 0;  pattern[11][2] = 0;  pattern[11][3] = 0;  pattern[11][4] = 1;  pattern[11][5] = 1;  pattern[11][6] = 0;  pattern[11][7] = 0;  pattern[11][8] = 0;  pattern[11][9] = 1;  pattern[11][10] = 1;  pattern[11][11] = 1;  pattern[11][12] = 0;  pattern[11][13] = 0;  pattern[11][14] = 0;  pattern[11][15] = 0;
       pattern[12][0] = 0;  pattern[12][1] = 0;  pattern[12][2] = 0;  pattern[12][3] = 0;  pattern[12][4] = 1;  pattern[12][5] = 1;  pattern[12][6] = 1;  pattern[12][7] = 1;  pattern[12][8] = 1;  pattern[12][9] = 1;  pattern[12][10] = 1;  pattern[12][11] = 1;  pattern[12][12] = 0;  pattern[12][13] = 0;  pattern[12][14] = 0;  pattern[12][15] = 0;
       pattern[13][0] = 0;  pattern[13][1] = 0;  pattern[13][2] = 0;  pattern[13][3] = 0;  pattern[13][4] = 0;  pattern[13][5] = 1;  pattern[13][6] = 1;  pattern[13][7] = 1;  pattern[13][8] = 1;  pattern[13][9] = 1;  pattern[13][10] = 0;  pattern[13][11] = 0;  pattern[13][12] = 0;  pattern[13][13] = 0;  pattern[13][14] = 0;  pattern[13][15] = 0;
       pattern[14][0] = 0;  pattern[14][1] = 0;  pattern[14][2] = 0;  pattern[14][3] = 0;  pattern[14][4] = 0;  pattern[14][5] = 0;  pattern[14][6] = 0;  pattern[14][7] = 0;  pattern[14][8] = 0;  pattern[14][9] = 0;  pattern[14][10] = 0;  pattern[14][11] = 0;  pattern[14][12] = 0;  pattern[14][13] = 0;  pattern[14][14] = 0;  pattern[14][15] = 0;
       pattern[15][0] = 0;  pattern[15][1] = 0;  pattern[15][2] = 0;  pattern[15][3] = 0;  pattern[15][4] = 0;  pattern[15][5] = 0;  pattern[15][6] = 0;  pattern[15][7] = 0;  pattern[15][8] = 0;  pattern[15][9] = 0;  pattern[15][10] = 0;  pattern[15][11] = 0;  pattern[15][12] = 0;  pattern[15][13] = 0;  pattern[15][14] = 0;  pattern[15][15] = 0;
    // Number 1 pattern
    //    pattern[0][0] = 0;  pattern[0][1] = 0;  pattern[0][2] = 0;  pattern[0][3] = 0;  pattern[0][4] = 0;  pattern[0][5] = 0;  pattern[0][6] = 0;  pattern[0][7] = 0;  pattern[0][8] = 0;  pattern[0][9] = 0;  pattern[0][10] = 0;  pattern[0][11] = 0;  pattern[0][12] = 0;  pattern[0][13] = 0;  pattern[0][14] = 0;  pattern[0][15] = 0;
    //    pattern[1][0] = 0;  pattern[1][1] = 0;  pattern[1][2] = 0;  pattern[1][3] = 0;  pattern[1][4] = 0;  pattern[1][5] = 0;  pattern[1][6] = 0;  pattern[1][7] = 0;  pattern[1][8] = 0;  pattern[1][9] = 0;  pattern[1][10] = 0;  pattern[1][11] = 0;  pattern[1][12] = 0;  pattern[1][13] = 0;  pattern[1][14] = 0;  pattern[1][15] = 0;
    //    pattern[2][0] = 0;  pattern[2][1] = 0;  pattern[2][2] = 0;  pattern[2][3] = 0;  pattern[2][4] = 0;  pattern[2][5] = 0;  pattern[2][6] = 0;  pattern[2][7] = 0;  pattern[2][8] = 1;  pattern[2][9] = 1;  pattern[2][10] = 1;  pattern[2][11] = 1;  pattern[2][12] = 0;  pattern[2][13] = 0;  pattern[2][14] = 0;  pattern[2][15] = 0;
    //    pattern[3][0] = 0;  pattern[3][1] = 0;  pattern[3][2] = 0;  pattern[3][3] = 0;  pattern[3][4] = 0;  pattern[3][5] = 0;  pattern[3][6] = 0;  pattern[3][7] = 0;  pattern[3][8] = 1;  pattern[3][9] = 1;  pattern[3][10] = 1;  pattern[3][11] = 1;  pattern[3][12] = 0;  pattern[3][13] = 0;  pattern[3][14] = 0;  pattern[3][15] = 0;
    //    pattern[4][0] = 0;  pattern[4][1] = 0;  pattern[4][2] = 0;  pattern[4][3] = 0;  pattern[4][4] = 0;  pattern[4][5] = 0;  pattern[4][6] = 0;  pattern[4][7] = 0;  pattern[4][8] = 1;  pattern[4][9] = 1;  pattern[4][10] = 1;  pattern[4][11] = 0;  pattern[4][12] = 0;  pattern[4][13] = 0;  pattern[4][14] = 0;  pattern[4][15] = 0;
    //    pattern[5][0] = 0;  pattern[5][1] = 0;  pattern[5][2] = 0;  pattern[5][3] = 0;  pattern[5][4] = 0;  pattern[5][5] = 0;  pattern[5][6] = 0;  pattern[5][7] = 1;  pattern[5][8] = 1;  pattern[5][9] = 1;  pattern[5][10] = 1;  pattern[5][11] = 0;  pattern[5][12] = 0;  pattern[5][13] = 0;  pattern[5][14] = 0;  pattern[5][15] = 0;
    //    pattern[6][0] = 0;  pattern[6][1] = 0;  pattern[6][2] = 0;  pattern[6][3] = 0;  pattern[6][4] = 0;  pattern[6][5] = 0;  pattern[6][6] = 0;  pattern[6][7] = 1;  pattern[6][8] = 1;  pattern[6][9] = 1;  pattern[6][10] = 0;  pattern[6][11] = 0;  pattern[6][12] = 0;  pattern[6][13] = 0;  pattern[6][14] = 0;  pattern[6][15] = 0;
    //    pattern[7][0] = 0;  pattern[7][1] = 0;  pattern[7][2] = 0;  pattern[7][3] = 0;  pattern[7][4] = 0;  pattern[7][5] = 0;  pattern[7][6] = 0;  pattern[7][7] = 1;  pattern[7][8] = 1;  pattern[7][9] = 1;  pattern[7][10] = 0;  pattern[7][11] = 0;  pattern[7][12] = 0;  pattern[7][13] = 0;  pattern[7][14] = 0;  pattern[7][15] = 0;
    //    pattern[8][0] = 0;  pattern[8][1] = 0;  pattern[8][2] = 0;  pattern[8][3] = 0;  pattern[8][4] = 0;  pattern[8][5] = 0;  pattern[8][6] = 0;  pattern[8][7] = 1;  pattern[8][8] = 1;  pattern[8][9] = 1;  pattern[8][10] = 0;  pattern[8][11] = 0;  pattern[8][12] = 0;  pattern[8][13] = 0;  pattern[8][14] = 0;  pattern[8][15] = 0;
    //    pattern[9][0] = 0;  pattern[9][1] = 0;  pattern[9][2] = 0;  pattern[9][3] = 0;  pattern[9][4] = 0;  pattern[9][5] = 0;  pattern[9][6] = 1;  pattern[9][7] = 1;  pattern[9][8] = 1;  pattern[9][9] = 1;  pattern[9][10] = 0;  pattern[9][11] = 0;  pattern[9][12] = 0;  pattern[9][13] = 0;  pattern[9][14] = 0;  pattern[9][15] = 0;
    //    pattern[10][0] = 0;  pattern[10][1] = 0;  pattern[10][2] = 0;  pattern[10][3] = 0;  pattern[10][4] = 0;  pattern[10][5] = 0;  pattern[10][6] = 1;  pattern[10][7] = 1;  pattern[10][8] = 1;  pattern[10][9] = 0;  pattern[10][10] = 0;  pattern[10][11] = 0;  pattern[10][12] = 0;  pattern[10][13] = 0;  pattern[10][14] = 0;  pattern[10][15] = 0;
    //    pattern[11][0] = 0;  pattern[11][1] = 0;  pattern[11][2] = 0;  pattern[11][3] = 0;  pattern[11][4] = 0;  pattern[11][5] = 0;  pattern[11][6] = 1;  pattern[11][7] = 1;  pattern[11][8] = 1;  pattern[11][9] = 0;  pattern[11][10] = 0;  pattern[11][11] = 0;  pattern[11][12] = 0;  pattern[11][13] = 0;  pattern[11][14] = 0;  pattern[11][15] = 0;
    //    pattern[12][0] = 0;  pattern[12][1] = 0;  pattern[12][2] = 0;  pattern[12][3] = 0;  pattern[12][4] = 0;  pattern[12][5] = 1;  pattern[12][6] = 1;  pattern[12][7] = 1;  pattern[12][8] = 1;  pattern[12][9] = 0;  pattern[12][10] = 0;  pattern[12][11] = 0;  pattern[12][12] = 0;  pattern[12][13] = 0;  pattern[12][14] = 0;  pattern[12][15] = 0;
    //    pattern[13][0] = 0;  pattern[13][1] = 0;  pattern[13][2] = 0;  pattern[13][3] = 0;  pattern[13][4] = 0;  pattern[13][5] = 1;  pattern[13][6] = 1;  pattern[13][7] = 1;  pattern[13][8] = 1;  pattern[13][9] = 0;  pattern[13][10] = 0;  pattern[13][11] = 0;  pattern[13][12] = 0;  pattern[13][13] = 0;  pattern[13][14] = 0;  pattern[13][15] = 0;
    //    pattern[14][0] = 0;  pattern[14][1] = 0;  pattern[14][2] = 0;  pattern[14][3] = 0;  pattern[14][4] = 0;  pattern[14][5] = 0;  pattern[14][6] = 0;  pattern[14][7] = 0;  pattern[14][8] = 0;  pattern[14][9] = 0;  pattern[14][10] = 0;  pattern[14][11] = 0;  pattern[14][12] = 0;  pattern[14][13] = 0;  pattern[14][14] = 0;  pattern[14][15] = 0;
    //    pattern[15][0] = 0;  pattern[15][1] = 0;  pattern[15][2] = 0;  pattern[15][3] = 0;  pattern[15][4] = 0;  pattern[15][5] = 0;  pattern[15][6] = 0;  pattern[15][7] = 0;  pattern[15][8] = 0;  pattern[15][9] = 0;  pattern[15][10] = 0;  pattern[15][11] = 0;  pattern[15][12] = 0;  pattern[15][13] = 0;  pattern[15][14] = 0;  pattern[15][15] = 0;
  end

   reg flattened_pattern [0:255];
   initial begin
    flattened_pattern = {
           pattern[0][0],  pattern[0][1],  pattern[0][2],  pattern[0][3],  pattern[0][4],  pattern[0][5],  pattern[0][6],  pattern[0][7],  pattern[0][8],  pattern[0][9],  pattern[0][10], pattern[0][11], pattern[0][12], pattern[0][13], pattern[0][14], pattern[0][15],
           pattern[1][0],  pattern[1][1],  pattern[1][2],  pattern[1][3],  pattern[1][4],  pattern[1][5],  pattern[1][6],  pattern[1][7],  pattern[1][8],  pattern[1][9],  pattern[1][10], pattern[1][11], pattern[1][12], pattern[1][13], pattern[1][14], pattern[1][15],
           pattern[2][0],  pattern[2][1],  pattern[2][2],  pattern[2][3],  pattern[2][4],  pattern[2][5],  pattern[2][6],  pattern[2][7],  pattern[2][8],  pattern[2][9],  pattern[2][10], pattern[2][11], pattern[2][12], pattern[2][13], pattern[2][14], pattern[2][15],
           pattern[3][0],  pattern[3][1],  pattern[3][2],  pattern[3][3],  pattern[3][4],  pattern[3][5],  pattern[3][6],  pattern[3][7],  pattern[3][8],  pattern[3][9],  pattern[3][10], pattern[3][11], pattern[3][12], pattern[3][13], pattern[3][14], pattern[3][15],
           pattern[4][0],  pattern[4][1],  pattern[4][2],  pattern[4][3],  pattern[4][4],  pattern[4][5],  pattern[4][6],  pattern[4][7],  pattern[4][8],  pattern[4][9],  pattern[4][10], pattern[4][11], pattern[4][12], pattern[4][13], pattern[4][14], pattern[4][15],
           pattern[5][0],  pattern[5][1],  pattern[5][2],  pattern[5][3],  pattern[5][4],  pattern[5][5],  pattern[5][6],  pattern[5][7],  pattern[5][8],  pattern[5][9],  pattern[5][10], pattern[5][11], pattern[5][12], pattern[5][13], pattern[5][14], pattern[5][15],
           pattern[6][0],  pattern[6][1],  pattern[6][2],  pattern[6][3],  pattern[6][4],  pattern[6][5],  pattern[6][6],  pattern[6][7],  pattern[6][8],  pattern[6][9],  pattern[6][10], pattern[6][11], pattern[6][12], pattern[6][13], pattern[6][14], pattern[6][15],
           pattern[7][0],  pattern[7][1],  pattern[7][2],  pattern[7][3],  pattern[7][4],  pattern[7][5],  pattern[7][6],  pattern[7][7],  pattern[7][8],  pattern[7][9],  pattern[7][10], pattern[7][11], pattern[7][12], pattern[7][13], pattern[7][14], pattern[7][15],
           pattern[8][0],  pattern[8][1],  pattern[8][2],  pattern[8][3],  pattern[8][4],  pattern[8][5],  pattern[8][6],  pattern[8][7],  pattern[8][8],  pattern[8][9],  pattern[8][10], pattern[8][11], pattern[8][12], pattern[8][13], pattern[8][14], pattern[8][15],
           pattern[9][0],  pattern[9][1],  pattern[9][2],  pattern[9][3],  pattern[9][4],  pattern[9][5],  pattern[9][6],  pattern[9][7],  pattern[9][8],  pattern[9][9],  pattern[9][10], pattern[9][11], pattern[9][12], pattern[9][13], pattern[9][14], pattern[9][15],
           pattern[10][0], pattern[10][1], pattern[10][2], pattern[10][3], pattern[10][4], pattern[10][5], pattern[10][6], pattern[10][7], pattern[10][8], pattern[10][9], pattern[10][10], pattern[10][11], pattern[10][12], pattern[10][13], pattern[10][14], pattern[10][15],
           pattern[11][0], pattern[11][1], pattern[11][2], pattern[11][3], pattern[11][4], pattern[11][5], pattern[11][6], pattern[11][7], pattern[11][8], pattern[11][9], pattern[11][10], pattern[11][11], pattern[11][12], pattern[11][13], pattern[11][14], pattern[11][15],
           pattern[12][0], pattern[12][1], pattern[12][2], pattern[12][3], pattern[12][4], pattern[12][5], pattern[12][6], pattern[12][7], pattern[12][8], pattern[12][9], pattern[12][10], pattern[12][11], pattern[12][12], pattern[12][13], pattern[12][14], pattern[12][15],
           pattern[13][0], pattern[13][1], pattern[13][2], pattern[13][3], pattern[13][4], pattern[13][5], pattern[13][6], pattern[13][7], pattern[13][8], pattern[13][9], pattern[13][10], pattern[13][11], pattern[13][12], pattern[13][13], pattern[13][14], pattern[13][15],
           pattern[14][0], pattern[14][1], pattern[14][2], pattern[14][3], pattern[14][4], pattern[14][5], pattern[14][6], pattern[14][7], pattern[14][8], pattern[14][9], pattern[14][10], pattern[14][11], pattern[14][12], pattern[14][13], pattern[14][14], pattern[14][15],
           pattern[15][0], pattern[15][1], pattern[15][2], pattern[15][3], pattern[15][4], pattern[15][5], pattern[15][6], pattern[15][7], pattern[15][8], pattern[15][9], pattern[15][10], pattern[15][11], pattern[15][12], pattern[15][13], pattern[15][14], pattern[15][15]
       };
   end

   

   reg   [INPUTS-1:0] x;
   always @(posedge clk) begin : set_inputs
     if (write_enable)
       x <= {x[INPUTS-8-1:0], ui_in[7:0]};
        // x <= flattened_pattern;
   end

   wire [OUTPUTS-1:0] y;
   wire [BITS_PER_CATEGORY*CATEGORIES-1:0] y_categories;
   net net(
     .in(x),
     .out(y),
     .categories(y_categories)
   );
 
   wire [BITS_PER_CATEGORY_SUM*CATEGORIES-1:0] sum_categories;
   genvar i;
   generate
     for (i = 0; i < CATEGORIES; i = i+1) begin : calc_categories
       `ifdef SYNTH
         sum_bits #(.N(BITS_PER_CATEGORY)) sum_bits(
       `else
         sum_255_bits sum_bits(
       `endif
           .y(y_categories[i*BITS_PER_CATEGORY +: 255]),
           .sum(sum_categories[i*BITS_PER_CATEGORY_SUM +: BITS_PER_CATEGORY_SUM])
       );
     end
   endgenerate
 
   wire [3:0] best_category_index;
   wire [7:0] best_category_value;
   arg_max_10 #(.N(BITS_PER_CATEGORY_SUM)) arg_max_categories(
     .categories(sum_categories),
     .out_index(best_category_index),
     .out_value(best_category_value)
   );
 
   assign  uo_out[7:0] = best_category_value[7:0];
   assign uio_out[3:0] = best_category_index[3:0];
   assign uio_out[6:4] = 0;
   assign uio_out[7]   = 0;
 
 endmodule
 
 module sum_bits #(
     parameter N = 16
 ) (
     input wire [N-1:0] y,
     output wire [$clog2(N)-1:0] sum
 );
     integer i;
     reg [$clog2(N)-1:0] temp_sum;
     
     always @(*) begin
         temp_sum = 0;
         for (i = 0; i < N; i = i + 1) begin
             temp_sum = temp_sum + y[i];
         end
     end
     
     assign sum = temp_sum;
 endmodule
 
 module sum_511_bits (
     input wire [512-1:0] y,
     output wire  [9-1:0] sum
 );
     wire [7:0] count0;
     wire [7:0] count1;
     PopCount256 popcount0(.data(y[0*256 +: 256]), .count(count0));
     PopCount256 popcount1(.data(y[1*256 +: 256]), .count(count1));
     wire unused_msb;
     assign {unused_msb, sum} = count0 + count1;
 endmodule
 
 module sum_255_bits (
     input wire [255-1:0] y,
     output wire  [8-1:0] sum
 );
     wire unused_msb;
     PopCount256 popcount256(.data({1'b0, y}), .count({unused_msb, sum}));
 endmodule
 
 module arg_max_10 #(
     parameter N = 8
 ) (
     input wire [10*N-1:0] categories,
     output reg [3:0] out_index,
     output reg [7:0] out_value
 );
     // Intermediate wires for the tree comparison
     (* mem2reg *) reg [N-1:0] max_value_stage1 [4:0];  // Stage 1: Compare adjacent pairs
     (* mem2reg *) reg [3:0]   max_index_stage1 [4:0]; 
 
     (* mem2reg *) reg [N-1:0] max_value_stage2 [2:0];  // Stage 2: Compare reduced pairs
     (* mem2reg *) reg [3:0]   max_index_stage2 [2:0]; 
 
                   reg [N-1:0] max_value_stage3;        // Stage 3: Final comparison
                   reg [3:0]   max_index_stage3;
 
     integer i;
 
     always @(*) begin
         // Stage 1: Compare adjacent pairs
         for (i = 0; i < 5; i = i + 1) begin
             if (categories[(2*i)*N +: N] > categories[(2*i+1)*N +: N]) begin
                 max_value_stage1[i] = categories[(2*i)*N +: N];
                 max_index_stage1[i] = 2*i;
             end else begin
                 max_value_stage1[i] = categories[(2*i+1)*N +: N];
                 max_index_stage1[i] = 2*i+1;
             end
         end
 
         // Stage 2: Compare reduced pairs
         for (i = 0; i < 2; i = i + 1) begin
             if (max_value_stage1[2*i] > max_value_stage1[2*i+1]) begin
                 max_value_stage2[i] = max_value_stage1[2*i];
                 max_index_stage2[i] = max_index_stage1[2*i];
             end else begin
                 max_value_stage2[i] = max_value_stage1[2*i+1];
                 max_index_stage2[i] = max_index_stage1[2*i+1];
             end
         end
         // Handle the last element (if odd number of inputs)
         max_value_stage2[2] = max_value_stage1[4];
         max_index_stage2[2] = max_index_stage1[4];
 
         // Stage 3: Final comparison
         if (max_value_stage2[0] > max_value_stage2[1]) begin
             if (max_value_stage2[0] > max_value_stage2[2]) begin
                 max_value_stage3 = max_value_stage2[0];
                 max_index_stage3 = max_index_stage2[0];
             end else begin
                 max_value_stage3 = max_value_stage2[2];
                 max_index_stage3 = max_index_stage2[2];
             end
         end else begin
             if (max_value_stage2[1] > max_value_stage2[2]) begin
                 max_value_stage3 = max_value_stage2[1];
                 max_index_stage3 = max_index_stage2[1];
             end else begin
                 max_value_stage3 = max_value_stage2[2];
                 max_index_stage3 = max_index_stage2[2];
             end
         end
 
         // Assign final max index
         out_index = max_index_stage3;
         out_value = max_value_stage3;
     end
 endmodule