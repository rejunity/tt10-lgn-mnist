/*
 * Copyright (c) 2024 ReJ aka Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`ifdef SIM
`elsif FPGA
`else
`define USE_HA_FA_CELLS
`endif

module PopCount256 (
  input [255:0] data,
  output  [8:0] count // 9 bits to hold from 0 to 256 (inclusive)
);
  wire [85+1-1:0] bit0_stage1;
  wire [28+2-1:0] bit0_stage2;
  wire [10  -1:0] bit0_stage3;
  wire [ 3+1-1:0] bit0_stage4;
  wire [ 1+1-1:0] bit0_stage5;
  wire [85  -1:0] bit1_stage1;
  wire [28  -1:0] bit1_stage2;
  wire [10  -1:0] bit1_stage3;
  wire [ 3  -1:0] bit1_stage4;
  wire            bit1_stage5;
  wire            bit1_stage6;
  Add256 ad0(.data(data),        .sum(bit0_stage1), .carry(bit1_stage1)); // 85
  Add86 add1(.data(bit0_stage1), .sum(bit0_stage2), .carry(bit1_stage2)); // 28
  Add30 add2(.data(bit0_stage2), .sum(bit0_stage3), .carry(bit1_stage3)); // 10
  Add10 add3(.data(bit0_stage3), .sum(bit0_stage4), .carry(bit1_stage4)); // 3
  Add4  add4(.data(bit0_stage4), .sum(bit0_stage5), .carry(bit1_stage5)); // 1
  Add2  add5(.data(bit0_stage5), .sum(count[0]),    .carry(bit1_stage6)); // 0.625

  wire [127:0] pop128 = {bit1_stage1, bit1_stage2, bit1_stage3, bit1_stage4, bit1_stage5, bit1_stage6};
  PopCount128 count128(.data(pop128), .count(count[8:1]));

endmodule

module PopCount128 (
  input [127:0] data,
  output  [7:0] count // 8 bits to hold from 0 to 128 (inclusive)
);
  wire [43:0] bit0_stage1;
  wire [15:0] bit0_stage2;
  wire [ 5:0] bit0_stage3;
  wire [ 1:0] bit0_stage4;
  wire [41:0] bit1_stage1;
  wire [13:0] bit1_stage2;
  wire [ 4:0] bit1_stage3;
  wire [ 1:0] bit1_stage4;
  wire        bit1_stage5;
  Add128 ad0(.data(data),        .sum(bit0_stage1), .carry(bit1_stage1)); // 42
  Add44 add1(.data(bit0_stage1), .sum(bit0_stage2), .carry(bit1_stage2)); // 14
  Add16 add3(.data(bit0_stage2), .sum(bit0_stage3), .carry(bit1_stage3)); // 5
  Add6  add4(.data(bit0_stage3), .sum(bit0_stage4), .carry(bit1_stage4)); // 2
  Add2  add5(.data(bit0_stage4), .sum(count[0]),    .carry(bit1_stage5)); // 0.625

  wire [63:0] pop64 = {bit1_stage1, bit1_stage2, bit1_stage3, bit1_stage4, bit1_stage5};
  PopCount64 count64(.data(pop64), .count(count[7:1]));

endmodule

module PopCount64 (
  input [63:0] data,
  output [6:0] count // 7 bits to hold from 0 to 64 (inclusive)
);
  wire [21:0] bit0_stage1;
  wire [ 7:0] bit0_stage2;
  wire [ 3:0] bit0_stage3;
  wire [ 1:0] bit0_stage4;
  wire [20:0] bit1_stage1;
  wire [ 6:0] bit1_stage2;
  wire [ 1:0] bit1_stage3;
  wire        bit1_stage4;
  wire        bit1_stage5;
  Add64 add1(.data(data),        .sum(bit0_stage1), .carry(bit1_stage1)); // 21
  Add22 add2(.data(bit0_stage1), .sum(bit0_stage2), .carry(bit1_stage2)); // 7
  Add8  add3(.data(bit0_stage2), .sum(bit0_stage3), .carry(bit1_stage3)); // 2
  Add4  add4(.data(bit0_stage3), .sum(bit0_stage4), .carry(bit1_stage4)); // 1
  Add2  add5(.data(bit0_stage4), .sum(count[0]),    .carry(bit1_stage5)); // 0.625

  wire [31:0] pop32 = {bit1_stage1, bit1_stage2, bit1_stage3, bit1_stage4, bit1_stage5};
  PopCount32 count32(.data(pop32), .count(count[6:1]));

endmodule

module PopCount32 (
    input [31:0] data,
    output [5:0] count // 6 bits to hold from 0 to 32 (inclusive)
);
  wire [11:0] bit0_stage1;
  wire [ 3:0] bit0_stage2;
  wire [ 1:0] bit0_stage3;
  wire        bit0_final;

  wire [ 9:0] bit1_stage1;
  wire [ 3:0] bit1_stage2;
  wire        bit1_stage3;
  wire        bit1_stage4;

  Add32 add1(.data(data),        .sum(bit0_stage1), .carry(bit1_stage1)); // 10
  Add12 add2(.data(bit0_stage1), .sum(bit0_stage2), .carry(bit1_stage2)); // 4
  Add4  add3(.data(bit0_stage2), .sum(bit0_stage3), .carry(bit1_stage3)); // 1
  Add2  add4(.data(bit0_stage3), .sum(bit0_final),  .carry(bit1_stage4)); // 0

  wire [ 5:0] bit1_stage5;
  wire [ 1:0] bit1_stage6;
  wire        bit1_final;

  wire [ 4:0] bit2_stage5;
  wire [ 1:0] bit2_stage6;
  wire        bit2_stage7;

  Add16 add5(.data({bit1_stage1, bit1_stage2, bit1_stage3, bit1_stage4}), .sum(bit1_stage5), .carry(bit2_stage5));  // 5
  Add6  add6(.data(bit1_stage5),                                          .sum(bit1_stage6), .carry(bit2_stage6));  // 2
  Add2  add7(.data(bit1_stage6),                                          .sum(bit1_final),  .carry(bit2_stage7));  // 0

  wire [ 3:0] bit2_stage8;
  wire [ 1:0] bit2_stage9;
  wire        bit2_final;

  wire [ 1:0] bit3_stage8;
  wire        bit3_stage9;
  wire        bit3_stage10;

  Add8  add8(.data({bit2_stage5, bit2_stage6, bit2_stage7}),              .sum(bit2_stage8), .carry(bit3_stage8));  // 2
  Add4  add9(.data(bit2_stage8),                                          .sum(bit2_stage9), .carry(bit3_stage9));  // 1
  Add2 add10(.data(bit2_stage9),                                          .sum(bit2_final),  .carry(bit3_stage10)); // 0

  wire [ 1:0] bit3_stage11;
  wire        bit3_final;

  wire        bit4_stage11;
  wire        bit4_stage12;

  Add4 add11(.data({bit3_stage8, bit3_stage9, bit3_stage10}),             .sum(bit3_stage11), .carry(bit4_stage11));  // 1
  Add2 add12(.data(bit3_stage11),                                         .sum(bit3_final),   .carry(bit4_stage12)); 

  wire        bit4_final, bit5_final;

  Add2 addFF(.data({bit4_stage12, bit4_stage11}),                         .sum(bit4_final),   .carry(bit5_final));

  // Output the final count
  assign count = {bit5_final, bit4_final, bit3_final, bit2_final, bit1_final, bit0_final};

endmodule


module Add256 (
    input  [255:0] data,
    output  [85:0] sum,
    output  [84:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 255; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[85] = data[255];
endmodule

module Add128 (
    input  [127:0] data,
    output  [43:0] sum,
    output  [41:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 126; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[43:42] = data[127:126];
endmodule

module Add86 (
    input  [85:0] data,
    output [29:0] sum,
    output [27:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 84; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[29:28] = data[85:84];
endmodule

module Add64 (
    input  [63:0] data,
    output [21:0] sum,
    output [20:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 63; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[21] = data[63];
endmodule

module Add44 (
    input  [43:0] data,
    output [15:0] sum,
    output [13:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 42; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[15:14] = data[43:42];
endmodule

module Add32 (
    input  [31:0] data,
    output [11:0] sum,
    output [ 9:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 30; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[11:10] = data[31:30];
endmodule

module Add30 (
    input  [29:0] data,
    output [ 9:0] sum,
    output [ 9:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 30; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
endmodule

module Add22 (
    input  [21:0] data,
    output [ 7:0] sum,
    output [ 6:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 21; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[7] = data[21];
endmodule

module Add16 (
    input  [15:0] data,
    output [ 5:0] sum,
    output [ 4:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 15; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[5] = data[15];
endmodule

module Add12 (
    input  [11:0] data,
    output [ 3:0] sum,
    output [ 3:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 12; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
endmodule

module Add10 (
    input  [ 9:0] data,
    output [ 3:0] sum,
    output [ 2:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 9; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[3] = data[9];
endmodule

module Add8 (
    input  [ 7:0] data,
    output [ 3:0] sum,
    output [ 1:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[3:2] = data[7:6];
endmodule

module Add6 (
    input  [ 5:0] data,
    output [ 1:0] sum,
    output [ 1:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
endmodule

module Add4 (
    input  [ 3:0] data,
    output [ 1:0] sum,
    output        carry
);
  CarrySaveAdder3 add3 (.a(data[0]), .b(data[1]), .c(data[2]),
                        .sum(sum[0]), .carry(carry));
  assign sum[1] = data[3];
endmodule


module Add2 (
    input  [ 1:0] data,
    output        sum,
    output        carry
);
  `ifdef USE_HA_FA_CELLS
    /* verilator lint_off PINMISSING */
    sky130_fd_sc_hd__ha_2 half_adder(.A(data[0]), .B(data[1]), .COUT(carry), .SUM(sum));
    /* verilator lint_on PINMISSING */
  `else
    CarrySaveAdder3 add3 (.a(data[0]), .b(data[1]), .c(1'b0),
                          .sum(sum), .carry(carry));
  `endif
endmodule

module CarrySaveAdder3 (
    input a,
    input b,
    input c,
    output sum,
    output carry
);
  `ifdef USE_HA_FA_CELLS
    /* verilator lint_off PINMISSING */
    sky130_fd_sc_hd__fa_2 full_adder(.A(a), .B(b), .CIN(c), .COUT(carry), .SUM(sum));
    /* verilator lint_on PINMISSING */
  `else
    assign sum = a ^ b ^ c;  // XOR for sum
    assign carry = (a & b) | (b & c) | (c & a);  // Majority function for carry
  `endif
endmodule

