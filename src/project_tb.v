// Testbench for project.v -- the top module of the design.
// This testbench was converted from cocotb tests/test.py into Verilog to reduce dependencies on cocotb.
// Could blame ChatGPT for any errors!

// Optional compile-time knobs (match cocotb flags conceptually)
`define SEVEN_SEGMENT
// `define CLEAR_BETWEEN_TEST_SAMPLES
`define CLEAR_WITH_ALTERNATING_PATTERN

`default_nettype none
`timescale 1ns/1ps
module project_tb;
  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("project_tb.vcd");
    $dumpvars(0, project_tb);
    #1;
  end

  // -------------------------
  // DUT interface (TinyTapeout-style)
  // -------------------------

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
// `ifdef GL_TEST
//   wire VPWR = 1'b1;
//   wire VGND = 1'b0;
// `endif

  tt_um_rejunity_lgn_mnist dut (
//       // Include power ports for the Gate Level test:
// `ifdef GL_TEST
//       .VPWR(VPWR),
//       .VGND(VGND),
// `endif
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

  // -------------------------
  // Parameters / test dataset
  // -------------------------

  net_testdata testdata();
  localparam X_BITS = `TESTDATA_X;
  localparam Y_BITS = `TESTDATA_Y;

  // -------------------------
  // Clock: 10 us period (100 kHz)
  // -------------------------
  initial clk = 1'b0;
  always #5000 clk = ~clk; // 5us half-period -> 10us full period

  // -------------------------
  // Helpers: 7-seg inverse
  // -------------------------
  function [3:0] seven_segment_inverse;
    input [6:0] seg;
    begin
      case (seg)
        7'b0111111: seven_segment_inverse = 0;
        7'b0000110: seven_segment_inverse = 1;
        7'b1011011: seven_segment_inverse = 2;
        7'b1001111: seven_segment_inverse = 3;
        7'b1100110: seven_segment_inverse = 4;
        7'b1101101: seven_segment_inverse = 5;
        7'b1111100: seven_segment_inverse = 6;
        7'b0000111: seven_segment_inverse = 7;
        7'b1111111: seven_segment_inverse = 8;
        7'b1100111: seven_segment_inverse = 9;
        default:    seven_segment_inverse = 4'hF; // invalid
      endcase
    end
  endfunction

  function [3:0] category_index;
    input dummy;
    reg [6:0] seg;
    begin
`ifdef SEVEN_SEGMENT
      seg = uo_out[6:0];
      category_index = seven_segment_inverse(seg);
`else
      category_index = uo_out[3:0];
`endif
    end
  endfunction

  function [7:0] category_value;
    input dummy;
    begin
      category_value = uio_out;
    end
  endfunction

  // -------------------------
  // Expected computation from Y (2550 bits)
  // Mirrors: categories = np.sum(y.reshape(10,-1), -1)
  // and: expected = len(categories)-1 - argmax(categories[::-1])
  // -------------------------
  task compute_expected_from_y;
    input  [Y_BITS-1:0] yvec;
    output integer expected_class;
    output integer expected_value;
    integer sums [0:9];
    integer i, c;
    integer start, stop;
    integer best_c;
    integer best_sum;
    integer chunk;
    integer rem;
    begin
      // initialize sums
      for (c = 0; c < 10; c = c + 1) sums[c] = 0;

      chunk = Y_BITS / 10;  // integer div
      rem   = 0;

      start = 0;
      for (c = 0; c < 10; c = c + 1) begin
        stop = start + chunk - 1;
        if (c == 9) stop = start + chunk + rem - 1;
        for (i = start; i <= stop; i = i + 1) begin
          // Treat bit i as belonging to class c
          sums[c] = sums[c] + yvec[i];
        end
        start = stop + 1;
      end

      // reverse-argmax trick to break ties like cocotb:
      // expected = 9 - argmax(sums[9:0])
      best_sum = -1;
      best_c   = 9; // because we scan reversed, first max encountered corresponds to highest original index
      for (c = 9; c >= 0; c = c - 1) begin
        if (sums[c] > best_sum) begin
          best_sum = sums[c];
          best_c   = c;
        end
      end
      expected_class = best_c;

      // expected value: int(categories[expected]) // 2
      expected_value = sums[expected_class] / 2;

      // optional print like cocotb
      $display("categories sums: [%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d]",
               sums[0],sums[1],sums[2],sums[3],sums[4],sums[5],sums[6],sums[7],sums[8],sums[9]);
    end
  endtask

  // -------------------------
  // Shift 256-bit sample into DUT (8-bit blocks per cycle)
  // Cocotb: x = x[::-1] then for each block_of_8 in split_array(x,8):
  // Here we send LSB-first bytes: ui_in = x_byte; then 1 cycle.
  // If your design expects MSB-first, flip the indexing below.
  // -------------------------
  task send_pixels;
    input [X_BITS-1:0] xvec;
    integer b;
    reg [7:0]  byte;
    begin
      for (b = 0; b < 32; b = b + 1) begin
        {byte, xvec} = {xvec, 8'b0};
        @(posedge clk);
        $write("%02b", byte);
        if (b[0] == 1'b1) begin
          $display(" best index: %0d value: %0d", category_index(0), category_value(0));
        end
        ui_in = byte;
      end
    end
  endtask

  // -------------------------
  // Optional "clear buffer" like cocotb
  // -------------------------
  task clear_input_buffer;
    input reg alt;
    integer i;
    begin
      ui_in  = alt ? 8'hFF : 8'h00;
      uio_in = 8'h00;
      for (i = 0; i < 32; i = i + 1) begin
        @(posedge clk);
        if (i[0] == 1'b1) begin
          if (!alt)
            $display("00000000... best index: %0d value: %0d", category_index(0), category_value(0));
          else
            $display("11111111... best index: %0d value: %0d", category_index(0), category_value(0));
        end
      end
    end
  endtask

  // -------------------------
  // Main test
  // -------------------------
  integer s;
  integer exp_class, exp_val;
  reg alt;

  initial begin
    $display("Start");

    // Reset sequence (matches cocotb)
    ena    = 1'b1;
    ui_in  = 8'h00;
    uio_in = 8'h00;
    rst_n  = 1'b0;

    repeat (10) @(posedge clk);
    rst_n = 1'b1;

    ui_in  = 8'h00;
    uio_in = 8'h00;
    repeat (32) @(posedge clk); // 256/8

    $display("Test network");
    alt = 1'b0;

    // Only first 8 samples (like cocotb)
    for (s = 0; s < $min(8, testdata.N); s = s + 1) begin
      $display("---- Sample %0d ----", s);

      $display("Clear input buffer, 256 bits");
`ifdef CLEAR_BETWEEN_TEST_SAMPLES
      clear_input_buffer(alt);
`ifdef CLEAR_WITH_ALTERNATING_PATTERN
      alt = ~alt;
`endif
`endif

      $display("Set input buffer, 256 bits");
      send_pixels(testdata.X[s]);

      // Latch / start pulse: cocotb sets ui_in=0; uio_in=128; 1 cycle
      ui_in  = 8'h00;
      uio_in = 8'h80;
      @(posedge clk);

      // Deassert
      uio_in = 8'h00;
      @(posedge clk);

      $display("Computed best index: %0d value: %0d", category_index(0), category_value(0));

      // Expected from Y
      compute_expected_from_y(testdata.Y[s], exp_class, exp_val);

      // Check category
      if (category_index(0) !== exp_class[3:0]) begin
        $display("FAIL category at sample %0d: expected %0d got %0d", s, exp_class, category_index(0));
        $finish(1);
      end

      // Check value (cocotb masks &127; yours used &255 in print helper sometimes; match cocotb assert: &127)
      if ( (category_value(0) & 8'h7F) !== (exp_val & 8'h7F) ) begin
        $display("FAIL value at sample %0d: expected %0d got %0d",
                 s, (exp_val & 8'h7F), (category_value(0) & 8'h7F));
        $finish(1);
      end

      $display("PASS sample %0d", s);
    end

    $display("ALL TESTS PASSED.");
    $finish;
  end

endmodule
