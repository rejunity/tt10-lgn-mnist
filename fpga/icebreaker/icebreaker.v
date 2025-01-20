module top (
    input  CLK,

    input BTN_N,
    input BTN1,
    input BTN2,
    input BTN3,

    output LED1,
    output LED2,
    output LED3,
    output LED4,
    output LED5,

    output LED_RED_N,
    output LED_GRN_N,
    output LED_BLU_N,

    input  wire[7:0] pmod_1a,
    output wire[7:0] pmod_1b
);
    reg [31:0] counter;
    reg flip;
    always @(posedge clk_pixel) begin
        counter <= counter + 1;
        if (counter == 12*1000*1000) begin
            flip <= ~flip;
            counter <= 0;
        end
    end

    tt_um_rejunity_lgn_mnist mnist(
        .ui_in(pmod_1a),
        .uo_out(pmod_1b),
        .uio_in({BTN1, 7'h00}),
        .uio_out({LED_RED_N, LED_GRN_N, LED_BLU_N, LED1, LED2, LED3, LED4, LED5}),
        .uio_oe(),
        .ena(1'b1),
        .clk(CLK),
        .rst_n(BTN_N)
    );


endmodule
