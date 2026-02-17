// Testbench for popcount.v

`default_nettype none
`timescale 1ns/1ps

module PopCount256_tb;

  reg  [255:0] data;
  wire [8:0]   count;

  // DUT
  PopCount256 dut (
    .data (data),
    .count(count)
  );

  // ------------------------------------------------------------
  // Reference popcount (plain Verilog)
  // ------------------------------------------------------------
  function [8:0] popcount256;
    input [255:0] x;
    integer i;
    integer s;
    begin
      s = 0;
      for (i = 0; i < 256; i = i + 1)
        s = s + x[i];
      popcount256 = s[8:0]; // 0..256 fits in 9 bits
    end
  endfunction

  // ------------------------------------------------------------
  // Random 256-bit vector using $random (iverilog-friendly)
  // ------------------------------------------------------------
  function [255:0] rand256;
    input dummy;
    reg [255:0] r;
    begin
      rand256 = r;
    end
  endfunction

  // ------------------------------------------------------------
  // Run one test case
  // ------------------------------------------------------------
  task run_one;
    input [255:0] vec;
    input [8*64-1:0] name; // up to 64 chars
    reg   [8:0] exp;
    begin
      data = vec;
      #1; // settle combinational logic
      exp = popcount256(vec);

      if (count !== exp) begin
        $display("FAIL %0s: exp=%0d (0x%0h) got=%0d (0x%0h)", name, exp, exp, count, count);
        $display("      data=%h", vec);
        $finish(1);
      end else begin
        // Comment out if you want quieter output
        // $display("PASS %0s: %0d", name, exp);
      end
    end
  endtask

  integer t;
  integer i;
  reg [255:0] v;

  initial begin
    data = 256'b0;
    #5;

    // Directed tests
    run_one(256'b0,                  "all_zeros");
    run_one({256{1'b1}},             "all_ones");     // expect 256
    run_one(256'h1,                  "lsb_one");      // expect 1
    run_one({255'b0,1'b1},           "bit0_set");
    run_one({1'b1,255'b0},           "bit255_set");
    $display("PASS: all_zeros, all_ones, lsb_one, bit0_set, bit255_set");

    // Alternating patterns (128 ones)
    run_one({128{2'b10}},            "alt_10");
    run_one({128{2'b01}},            "alt_01");
    $display("PASS: alt_10, alt_01");

    // Walking ones (all 256 positions)
    for (i = 0; i < 256; i = i + 1) begin
      v = 256'b0;
      v[i] = 1'b1;
      run_one(v, "walking_one");
    end
    $display("PASS: walking_one variations");

    // Walking zeros (all 256 positions) from all-ones
    for (i = 0; i < 256; i = i + 1) begin
      v = {256{1'b1}};
      v[i] = 1'b0;
      run_one(v, "walking_zero");
    end
    $display("PASS: walking_zero variations");

    // Random tests
    for (t = 0; t < 2000; t = t + 1) begin
      v[ 31:  0] = $random;
      v[ 63: 32] = $random;
      v[ 95: 64] = $random;
      v[127: 96] = $random;
      v[159:128] = $random;
      v[191:160] = $random;
      v[223:192] = $random;
      v[255:224] = $random;
      run_one(v, "random");
      if (t % 100 == 0)
      begin
        $display("PASS: 100 random vectors");
      end
    end
    // $display("PASS: 2000 random vectors");

    $display("ALL TESTS PASSED.");
    $finish;
  end

endmodule