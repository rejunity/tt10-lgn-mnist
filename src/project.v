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
   always @(posedge clk) begin : set_inputs
     if (write_enable)
       x <= {x[INPUTS-8-1:0], ui_in[7:0]};
   end
 
   reg   [INPUTS-1:0] x;
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