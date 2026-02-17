// Testbench for net.v

`default_nettype none
`timescale 1ns/1ps
module net_tb;
  reg  [(`TESTDATA_X)-1:0] in;
  wire [(`TESTDATA_Y)-1:0] out;

  net dut(
    .in(in),
    .out(out)
  );

  net_testdata testdata();
    
  integer i;
  initial begin
    $display("Running %0d vectors...", testdata.N);
    for (i = 0; i < testdata.N; i = i + 1) begin
      in = testdata.X[i];
       #1;
      if (out !== testdata.Y[i]) begin
        $display("FAIL at i=%0d", i);
        $display("  in  = %b", in);
        $display("  exp = %b", testdata.Y[i]);
        $display("  got = %b", out);
        $finish(1);
      end
    end
    $display("ALL TESTS PASSED.");
    $finish;
  end
endmodule
