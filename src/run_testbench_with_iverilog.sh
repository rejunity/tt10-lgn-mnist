rm -f popcount_tb.vvp
rm -f net_tb.vvp
rm -f project_tb.vvp
iverilog -DSIM -g2005 -o popcount_tb.vvp popcount.v popcount_tb.v; vvp popcount_tb.vvp
iverilog -DSIM -g2005 -o net_tb.vvp net.v popcount.v net_testdata.v net_tb.v; vvp net_tb.vvp
iverilog -DSIM -g2005 -o project_tb.vvp net.v popcount.v project.v net_testdata.v project_tb.v; vvp project_tb.vvp
