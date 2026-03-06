/*
 * Copyright (c) 2024 Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    inout  wire [7:0] uio,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    wire [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_iobuf
            IOBUF iobuf_inst (
                .I(uio_out[i]),
                .O(uio_in[i]),
                .IO(uio[i]),
                .T(~uio_oe[i])
            );
        end
    endgenerate

    tt_um_rejunity_lgn_mnist dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
endmodule
