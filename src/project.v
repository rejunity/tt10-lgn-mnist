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

  assign uio_oe  = 8'b0111_1111; // BIDIR in output mode, except the highest bit

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, rst_n, 1'b0};

  localparam INPUTS  = 256;
  localparam OUTPUTS = 4000;
  localparam CATEGORIES = 10;
  localparam BITS_PER_CATEGORY = 256;
  always @(posedge clk) begin : set_inputs
    // if (~uio_in[7])
    x <= {x[INPUTS-8:0], ui_in[7:0]};
  end

  reg   [INPUTS-1:0] x;
  wire [OUTPUTS-1:0] y;
  // wire [BITS_PER_CATEGORY-1:0] categories [CATEGORIES-1:0];
  wire [BITS_PER_CATEGORY*CATEGORIES-1:0] y_categories;
  net net(.in(x), .out(y),
    .categories(y_categories)
    // .class_2(categories[2]),
    // .class_3(categories[3]),
    // .class_4(categories[4]),
    // .class_5(categories[5]),
    // .class_6(categories[6]),
    // .class_7(categories[7]),
    // .class_8(categories[8]),
    // .class_9(categories[9])
    );

  // wire [7:0] categories [CATEGORIES-1:0];
  wire [8*CATEGORIES-1:0] categories;
  // genvar i;
  // generate
  //   for (i = 0; i < CATEGORIES; i = i+1) begin : categories
  //     sum_bits #(.N(BITS_PER_CATEGORY)) sum_bits (.y(y_categories[(i+1)*BITS_PER_CATEGORY-1 -: BITS_PER_CATEGORY]), .sum(categories[i]));
  //   end
  // endgenerate

  sum_bits #(.N(256)) sum_categories_0 (.y(y_categories[ 1*256-1: 0*256]), .sum(categories[ 1*8-1:0*8]));
  sum_bits #(.N(256)) sum_categories_1 (.y(y_categories[ 2*256-1: 1*256]), .sum(categories[ 2*8-1:1*8]));
  sum_bits #(.N(256)) sum_categories_2 (.y(y_categories[ 3*256-1: 2*256]), .sum(categories[ 3*8-1:2*8]));
  sum_bits #(.N(256)) sum_categories_3 (.y(y_categories[ 4*256-1: 3*256]), .sum(categories[ 4*8-1:3*8]));
  sum_bits #(.N(256)) sum_categories_4 (.y(y_categories[ 5*256-1: 4*256]), .sum(categories[ 5*8-1:4*8]));
  sum_bits #(.N(256)) sum_categories_5 (.y(y_categories[ 6*256-1: 5*256]), .sum(categories[ 6*8-1:5*8]));
  sum_bits #(.N(256)) sum_categories_6 (.y(y_categories[ 7*256-1: 6*256]), .sum(categories[ 7*8-1:6*8]));
  sum_bits #(.N(256)) sum_categories_7 (.y(y_categories[ 8*256-1: 7*256]), .sum(categories[ 8*8-1:7*8]));
  sum_bits #(.N(256)) sum_categories_8 (.y(y_categories[ 9*256-1: 8*256]), .sum(categories[ 9*8-1:8*8]));
  sum_bits #(.N(256)) sum_categories_9 (.y(y_categories[10*256-1: 9*256]), .sum(categories[10*8-1:9*8]));

  wire [3:0] best_category_index;
  wire [7:0] best_category_value;
  arg_max_10 arg_max_categories(.categories(categories), .max_index(best_category_index), .max_value(best_category_value));
  // initial
  //     $monitor("best:%d", best_category_index);
  // initial
  //   $monitor("0:%d 1:%d 2:%d 3:%d 4:%d 5:%d 6:%d 7:%d 8:%d 9:%d ", categories[0], categories[1], categories[2], categories[3], categories[4], categories[5], categories[6], categories[7],  categories[8], categories[9]);

  wire [14:0] sum;
  // sum_bits #(.N(OUTPUTS)) sum_outputs (.y(y), .sum(sum));
  assign sum =  categories[ 1*8-1:0*8] +
                categories[ 2*8-1:1*8] +
                categories[ 3*8-1:2*8] +
                categories[ 4*8-1:3*8] +
                categories[ 5*8-1:4*8] +
                categories[ 6*8-1:5*8] +
                categories[ 7*8-1:6*8] +
                categories[ 8*8-1:7*8] +
                categories[ 9*8-1:8*8] +
                categories[10*8-1:9*8] ;
  assign  uo_out[7:0] = best_category_value;
  assign uio_out[3:0] = best_category_index;
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

module arg_max_10(
    input wire [10*8-1:0] categories,
    output reg [3:0] max_index,
    output reg [7:0] max_value
);
    // Intermediate wires for the tree comparison
    reg [7:0] max_value_stage1 [4:0];  // Stage 1: Compare adjacent pairs
    reg [3:0] max_index_stage1 [4:0]; 

    reg [7:0] max_value_stage2 [2:0];  // Stage 2: Compare reduced pairs
    reg [3:0] max_index_stage2 [2:0]; 

    reg [7:0] max_value_stage3;        // Stage 3: Final comparison
    reg [3:0] max_index_stage3;

    integer i;

    always @(*) begin
        // Stage 1: Compare adjacent pairs
        for (i = 0; i < 5; i = i + 1) begin
            if (categories[(2*i)*8 +: 8] > categories[(2*i+1)*8 +: 8]) begin
                max_value_stage1[i] = categories[(2*i)*8 +: 8];
                max_index_stage1[i] = 2*i;
            end else begin
                max_value_stage1[i] = categories[(2*i+1)*8 +: 8];
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
        max_index = max_index_stage3;
        max_value = max_value_stage3;
    end
endmodule
