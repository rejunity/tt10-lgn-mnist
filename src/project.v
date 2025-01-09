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

  // wire [14:0] y;
  // net net(.in(ui_in[1:0]), .out(y));
  // // assign uo_out[7:0] =         y[ 7:0];
  // // assign uio_out[7:0] = {1'b0, y[14:8]};

  // wire [15:0] sum;
  // sum_bits #(.N(15)) sum_outputs (.y(y), .sum(sum));
  // assign uo_out[7:0]  = sum[ 7:0];
  // assign uio_out[7:0] = sum[15:8];


  localparam INPUTS  = 256;
  localparam OUTPUTS = 4000;
  always @(posedge clk) begin : set_inputs
    if (~uio_in[7])
      x <= {x[INPUTS-8:0], ui_in[7:0]};
  end

  reg   [INPUTS-1:0] x;
  wire [OUTPUTS-1:0] y;
  net net(.in(x), .out(y));

  wire [14:0] sum;
  sum_bits #(.N(OUTPUTS)) sum_outputs (.y(y), .sum(sum));
  assign uo_out[7:0]  = sum[ 7:0];
  assign uio_out[6:0] = sum[14:8];
  assign uio_out[7] = 0;

  /////////////////////////////////////////////////
  // localparam N = 15;
  // localparam CLASSES = 3;
  // wire [CLASSES*N-1:0] y;
  // reg [15:0] sum = 0;
  // genvar i, c;
  // generate
  //   for (c = 0; c < CLASSES; c = c+1) begin
  //     for (i = 0; i < N; i = i+1) begin
  //       always @*
  //         sum = sum + y[c * N + i];
  //     end
  //   end
  // endgenerate

  // reg [15:0] sum [CLASSES-1:0];
  // genvar i, c;
  // generate
  //   for (c = 0; c < CLASSES; c = c+1) begin
  //     for (i = 0; i < N; i = i+1) begin
  //       always @*
  //         sum[c] = sum[c] + y[c * N + i];
  //     end
  //   end
  // endgenerate

  // wire [3:0] clazz = uio_in[3:0];
  // wire [15:0] out = sum[clazz];
  // assign uo_out[7:0] = out[7:0];

endmodule

module sum_bits #(
    parameter N = 16
) (
    input wire [N-1:0] y,
    output wire [$clog2(N):0] sum
);
    integer i;
    reg [$clog2(N):0] temp_sum;
    
    always @(*) begin
        temp_sum = 0;
        for (i = 0; i < N; i = i + 1) begin
            temp_sum = temp_sum + y[i];
        end
    end
    
    assign sum = temp_sum;
endmodule
