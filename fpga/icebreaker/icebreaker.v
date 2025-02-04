// `define AUTO_SWITCH_ON_TIMER

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

    output wire[7:0] pmod_1a,
    output wire[7:0] pmod_1b
);
    reg [31:0] counter;
    reg flip;
    always @(posedge CLK) begin
        counter <= counter + 1;
        if (counter == 12*1000*1000) begin
            flip <= ~flip;
            counter <= 0;
        end
    end

    assign LED1 = BTN1;
    assign LED2 = flip;

    wire [3:0] index;
    wire [7:0] value;
    reg [7:0] pattern5[0:31];
    reg [7:0] pattern6[0:31];
    reg [7:0] pattern3[0:31];
    reg [7:0] pattern9[0:31];
    initial begin
        // 5
        pattern5[5'd00] = 8'b00000000; pattern5[5'd01] = 8'b00000000;
        pattern5[5'd02] = 8'b00000000; pattern5[5'd03] = 8'b00000000;
        pattern5[5'd04] = 8'b00000111; pattern5[5'd05] = 8'b11111000;
        pattern5[5'd06] = 8'b00011111; pattern5[5'd07] = 8'b11111100;
        pattern5[5'd08] = 8'b00111100; pattern5[5'd09] = 8'b00000000;
        pattern5[5'd10] = 8'b00110000; pattern5[5'd11] = 8'b00000000;
        pattern5[5'd12] = 8'b00110000; pattern5[5'd13] = 8'b00000000;
        pattern5[5'd14] = 8'b00011111; pattern5[5'd15] = 8'b00011000;
        pattern5[5'd16] = 8'b00001111; pattern5[5'd17] = 8'b11111000;
        pattern5[5'd18] = 8'b00000000; pattern5[5'd19] = 8'b01111000;
        pattern5[5'd20] = 8'b00000000; pattern5[5'd21] = 8'b00110000;
        pattern5[5'd22] = 8'b00000000; pattern5[5'd23] = 8'b11110000;
        pattern5[5'd24] = 8'b00001111; pattern5[5'd25] = 8'b11110000;
        pattern5[5'd26] = 8'b00000111; pattern5[5'd27] = 8'b00000000;
        pattern5[5'd28] = 8'b00000000; pattern5[5'd29] = 8'b00000000;
        pattern5[5'd30] = 8'b00000000; pattern5[5'd31] = 8'b00000000;
        // 6 [18]
        pattern6[5'd00] = 8'b00000000; pattern6[5'd01] = 8'b00000000;
        pattern6[5'd02] = 8'b00000000; pattern6[5'd03] = 8'b00000000;
        pattern6[5'd04] = 8'b00000000; pattern6[5'd05] = 8'b00000000;
        pattern6[5'd06] = 8'b00000001; pattern6[5'd07] = 8'b11000000;
        pattern6[5'd08] = 8'b00000111; pattern6[5'd09] = 8'b11110000;
        pattern6[5'd10] = 8'b00001111; pattern6[5'd11] = 8'b11111000;
        pattern6[5'd12] = 8'b00011101; pattern6[5'd13] = 8'b11011000;
        pattern6[5'd14] = 8'b00011111; pattern6[5'd15] = 8'b10110000;
        pattern6[5'd16] = 8'b00011111; pattern6[5'd17] = 8'b01110000;
        pattern6[5'd18] = 8'b00001100; pattern6[5'd19] = 8'b11100000;
        pattern6[5'd20] = 8'b00000001; pattern6[5'd21] = 8'b11000000;
        pattern6[5'd22] = 8'b00000011; pattern6[5'd23] = 8'b10000000;
        pattern6[5'd24] = 8'b00000111; pattern6[5'd25] = 8'b00000000;
        pattern6[5'd26] = 8'b00001110; pattern6[5'd27] = 8'b00000000;
        pattern6[5'd28] = 8'b00001100; pattern6[5'd29] = 8'b00000000;
        pattern6[5'd30] = 8'b00001100; pattern6[5'd31] = 8'b00000000;
        // 3 [20] -- does not work
        pattern3[5'd00] = 8'b00000000; pattern3[5'd01] = 8'b00000000;
        pattern3[5'd02] = 8'b00000001; pattern3[5'd03] = 8'b11100000;
        pattern3[5'd04] = 8'b00000111; pattern3[5'd05] = 8'b11110000;
        pattern3[5'd06] = 8'b00001111; pattern3[5'd07] = 8'b00110000;
        pattern3[5'd08] = 8'b00001100; pattern3[5'd09] = 8'b00000000;
        pattern3[5'd10] = 8'b00001100; pattern3[5'd11] = 8'b00000000;
        pattern3[5'd12] = 8'b00001110; pattern3[5'd13] = 8'b00000000;
        pattern3[5'd14] = 8'b00001111; pattern3[5'd15] = 8'b11110000;
        pattern3[5'd16] = 8'b00000111; pattern3[5'd17] = 8'b11110000;
        pattern3[5'd18] = 8'b00000001; pattern3[5'd19] = 8'b10000000;
        pattern3[5'd20] = 8'b00000011; pattern3[5'd21] = 8'b10110000;
        pattern3[5'd22] = 8'b00000011; pattern3[5'd23] = 8'b11110000;
        pattern3[5'd24] = 8'b00000011; pattern3[5'd25] = 8'b11110000;
        pattern3[5'd26] = 8'b00000011; pattern3[5'd27] = 8'b11000000;
        pattern3[5'd28] = 8'b00000000; pattern3[5'd29] = 8'b00000000;
        pattern3[5'd30] = 8'b00000000; pattern3[5'd31] = 8'b00000000;           
        // 9 [30]
        pattern9[5'd00] = 8'b00000001; pattern9[5'd01] = 8'b11000000;
        pattern9[5'd02] = 8'b00000001; pattern9[5'd03] = 8'b11000000;
        pattern9[5'd04] = 8'b00000001; pattern9[5'd05] = 8'b11000000;
        pattern9[5'd06] = 8'b00000011; pattern9[5'd07] = 8'b10000000;
        pattern9[5'd08] = 8'b00000011; pattern9[5'd09] = 8'b10000000;
        pattern9[5'd10] = 8'b00000111; pattern9[5'd11] = 8'b00000000;
        pattern9[5'd12] = 8'b00000111; pattern9[5'd13] = 8'b11100000;
        pattern9[5'd14] = 8'b00001111; pattern9[5'd15] = 8'b11110000;
        pattern9[5'd16] = 8'b00001111; pattern9[5'd17] = 8'b00111000;
        pattern9[5'd18] = 8'b00011100; pattern9[5'd19] = 8'b01110000;
        pattern9[5'd20] = 8'b00011111; pattern9[5'd21] = 8'b11110000;
        pattern9[5'd22] = 8'b00001111; pattern9[5'd23] = 8'b11100000;
        pattern9[5'd24] = 8'b00000111; pattern9[5'd25] = 8'b00000000;
        pattern9[5'd26] = 8'b00000000; pattern9[5'd27] = 8'b00000000;
        pattern9[5'd28] = 8'b00000000; pattern9[5'd29] = 8'b00000000;
        pattern9[5'd30] = 8'b00000000; pattern9[5'd31] = 8'b00000000;           
    end

    reg [7:0] current_pattern_byte;
    reg [3:0] latched_index;
    reg [7:0] latched_value;
    reg [4:0] i;

    wire slow_clk;
    clock_div2 clock_div2(
        .clk_12MHz(CLK),
        .clk_6MHz(slow_clk)
    );

    always @(posedge slow_clk) begin
        current_pattern_byte <= (flip) ? pattern5[i] : pattern3[i];
        // current_pattern_byte <= (flip) ? pattern5[i] : pattern6[i];
        // current_pattern_byte <= (flip) ? 8'hFF : pattern3[i];
        if (i == 1) latched_index <= index;
        if (i == 1) latched_value <= value;
        i <= i + 1;
    end
    // true 5 | 6 | 3 | 9
    //----------------------
    // -2 ~ ? | 4 |   | 
    // +0 ~ 5 | 6 | 1 | 9
    // +1 ~ ? | 0 |   |
    // +2 ~ 5 | 6 | 1 | 9
    // +3 ~ 2 | ? | 2 |
    // +4 ~ 5 | 6 | 9 | 9
    // +5 ~ 2 | ? | 2 |
    // +6 ~ 5 | 1 | 9 | 6
    // +7 ~ 2 | ? |   |
    // +8 ~ 1 | 2 | 6 | 6 
    // +9 ~ 1
    
    tt_um_rejunity_lgn_mnist mnist(
        .ui_in(current_pattern_byte),
        .uo_out(value),
        .uio_in({BTN2, 7'h00}),
        .uio_out(index),
        .uio_oe(),
        .ena(1'b1),
        .clk(slow_clk),
        .rst_n(BTN_N)
    );

    seven_segment seven_segment(
        .in(latched_index),
        .out(pmod_1b)
    );

    assign pmod_1a = ~{latched_value[3:0], latched_value[7:4]};

    // tt_um_rejunity_lgn_mnist mnist(
    //     .ui_in(pmod_1a),
    //     .uo_out(pmod_1b),
    //     .uio_in({BTN1, 7'h00}),
    //     .uio_out({LED_RED_N, LED_GRN_N, LED_BLU_N, LED1, LED2, LED3, LED4, LED5}),
    //     .uio_oe(),
    //     .ena(1'b1),
    //     .clk(CLK),
    //     .rst_n(BTN_N)
    // );


endmodule

//          A
//         ---
//        |   |
//      F | G | B
//         ---
//        |   |
//      E | D | C
//         ---

module seven_segment (
    input  wire [3:0] in,
    output reg  [6:0] out
);
    always @(*) begin
        case(in)           // GFEDCBA
        4'd0:       out = ~7'b0111111; // "0"  
        4'd1:       out = ~7'b0000110; // "1" 
        4'd2:       out = ~7'b1011011; // "2" 
        4'd3:       out = ~7'b1001111; // "3" 
        4'd4:       out = ~7'b1100110; // "4" 
        4'd5:       out = ~7'b1101101; // "5" 
        4'd6:       out = ~7'b1111101; // "6" 
        4'd7:       out = ~7'b0000111; // "7" 
        4'd8:       out = ~7'b1111111; // "8"  
        4'd9:       out = ~7'b1101111; // "9" 
        default:    out = ~7'b0111111; // "0"
        endcase
    end
endmodule

//
// Clock divider(s) for sub 12MHz execution
//

module clock_pll (
    input  wire clk_12MHz,   // Input: 12 MHz clock
    output wire clk_6MHz,    // Output: 6 MHz clock (divided by 2)
    output wire succeeded
);    
    SB_PLL40_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),       // Reference clock divider (÷1)
        .DIVF(7'b0000010),    // Multiplier (x2)
        .DIVQ(3'b011),        // Divider (÷4) → 12MHz * (2/4) = 6MHz
        .FILTER_RANGE(3'b001)
    ) pll_inst (
        .PACKAGEPIN(clk_12MHz),
        .PLLOUTCORE(clk_6MHz),
        .LOCK(succeeded),
        .BYPASS(1'b0),
        .RESETB(1'b1)
    );
endmodule

module clock_div2 (
    input  wire clk_12MHz,
    output wire clk_6MHz
);
    wire global_clk_buffer;

    reg clk_divider;
    always @(posedge clk_12MHz) clk_divider <= ~clk_divider;

    SB_GB clk_buffer (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clk_divider),
        .GLOBAL_BUFFER_OUTPUT(global_clk_buffer)
    );

    assign clk_6MHz = global_clk_buffer;
endmodule
