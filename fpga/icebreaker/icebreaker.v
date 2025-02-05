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

    // output wire[7:0] pmod_1a,
    output wire[7:0] pmod_1b,

    output reg  SCLK,     // SPI clock to OLED
    output reg  MOSI,     // SPI MOSI
    output reg  CS,       // SPI chip select (active-low)
    output reg  DC,       // OLED D/C (0=command, 1=data)
    output reg  RES,      // OLED reset (active-low)
    output reg  VBATC,    // OLED VBAT control (active-low)
    output reg  VDDC      // OLED VDD  control (active-low)
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

    reg [7:0] pattern5 [0:31];
    initial begin
        pattern5[0] = 8'b00000000;
        pattern5[1] = 8'b00000000;
        pattern5[2] = 8'b00000000;
        pattern5[3] = 8'b00000000;
        pattern5[4] = 8'b00000111;
        pattern5[5] = 8'b11111000;
        pattern5[6] = 8'b00011111;
        pattern5[7] = 8'b11111100;
        pattern5[8] = 8'b00111100;
        pattern5[9] = 8'b00000000;
        pattern5[10] = 8'b00110000;
        pattern5[11] = 8'b00000000;
        pattern5[12] = 8'b00110000;
        pattern5[13] = 8'b00000000;
        pattern5[14] = 8'b00011111;
        pattern5[15] = 8'b00011000;
        pattern5[16] = 8'b00001111;
        pattern5[17] = 8'b11111000;
        pattern5[18] = 8'b00000000;
        pattern5[19] = 8'b01111000;
        pattern5[20] = 8'b00000000;
        pattern5[21] = 8'b00110000;
        pattern5[22] = 8'b00000000;
        pattern5[23] = 8'b11110000;
        pattern5[24] = 8'b00001111;
        pattern5[25] = 8'b11110000;
        pattern5[26] = 8'b00000111;
        pattern5[27] = 8'b00000000;
        pattern5[28] = 8'b00000000;
        pattern5[29] = 8'b00000000;
        pattern5[30] = 8'b00000000;
        pattern5[31] = 8'b00000000;
    end

    reg [7:0] pattern9 [0:31];
    initial begin
        pattern9[0] = 8'b00000001;
        pattern9[1] = 8'b11000000;
        pattern9[2] = 8'b00000001;
        pattern9[3] = 8'b11000000;
        pattern9[4] = 8'b00000001;
        pattern9[5] = 8'b11000000;
        pattern9[6] = 8'b00000011;
        pattern9[7] = 8'b10000000;
        pattern9[8] = 8'b00000011;
        pattern9[9] = 8'b10000000;
        pattern9[10] = 8'b00000111;
        pattern9[11] = 8'b00000000;
        pattern9[12] = 8'b00000111;
        pattern9[13] = 8'b11100000;
        pattern9[14] = 8'b00001111;
        pattern9[15] = 8'b11110000;
        pattern9[16] = 8'b00001111;
        pattern9[17] = 8'b00111000;
        pattern9[18] = 8'b00011100;
        pattern9[19] = 8'b01110000;
        pattern9[20] = 8'b00011111;
        pattern9[21] = 8'b11110000;
        pattern9[22] = 8'b00001111;
        pattern9[23] = 8'b11100000;
        pattern9[24] = 8'b00000111;
        pattern9[25] = 8'b00000000;
        pattern9[26] = 8'b00000000;
        pattern9[27] = 8'b00000000;
        pattern9[28] = 8'b00000000;
        pattern9[29] = 8'b00000000;
        pattern9[30] = 8'b00000000;
        pattern9[31] = 8'b00000000;
    end

    // reg [7:0] pattern [0:31];
    // initial begin
        // 5
        // pattern[0] = 8'b00000000;
        // pattern[1] = 8'b00000000;
        // pattern[2] = 8'b00000000;
        // pattern[3] = 8'b00000000;
        // pattern[4] = 8'b00000111;
        // pattern[5] = 8'b11111000;
        // pattern[6] = 8'b00011111;
        // pattern[7] = 8'b11111100;
        // pattern[8] = 8'b00111100;
        // pattern[9] = 8'b00000000;
        // pattern[10] = 8'b00110000;
        // pattern[11] = 8'b00000000;
        // pattern[12] = 8'b00110000;
        // pattern[13] = 8'b00000000;
        // pattern[14] = 8'b00011111;
        // pattern[15] = 8'b00011000;
        // pattern[16] = 8'b00001111;
        // pattern[17] = 8'b11111000;
        // pattern[18] = 8'b00000000;
        // pattern[19] = 8'b01111000;
        // pattern[20] = 8'b00000000;
        // pattern[21] = 8'b00110000;
        // pattern[22] = 8'b00000000;
        // pattern[23] = 8'b11110000;
        // pattern[24] = 8'b00001111;
        // pattern[25] = 8'b11110000;
        // pattern[26] = 8'b00000111;
        // pattern[27] = 8'b00000000;
        // pattern[28] = 8'b00000000;
        // pattern[29] = 8'b00000000;
        // pattern[30] = 8'b00000000;
        // pattern[31] = 8'b00000000;
        // // 6 [18]
        // pattern[0] = 8'b00000000;
        // pattern[1] = 8'b00000000;
        // pattern[2] = 8'b00000000;
        // pattern[3] = 8'b00000000;
        // pattern[4] = 8'b00000000;
        // pattern[5] = 8'b00000000;
        // pattern[6] = 8'b00000001;
        // pattern[7] = 8'b11000000;
        // pattern[8] = 8'b00000111;
        // pattern[9] = 8'b11110000;
        // pattern[10] = 8'b00001111;
        // pattern[11] = 8'b11111000;
        // pattern[12] = 8'b00011101;
        // pattern[13] = 8'b11011000;
        // pattern[14] = 8'b00011111;
        // pattern[15] = 8'b10110000;
        // pattern[16] = 8'b00011111;
        // pattern[17] = 8'b01110000;
        // pattern[18] = 8'b00001100;
        // pattern[19] = 8'b11100000;
        // pattern[20] = 8'b00000001;
        // pattern[21] = 8'b11000000;
        // pattern[22] = 8'b00000011;
        // pattern[23] = 8'b10000000;
        // pattern[24] = 8'b00000111;
        // pattern[25] = 8'b00000000;
        // pattern[26] = 8'b00001110;
        // pattern[27] = 8'b00000000;
        // pattern[28] = 8'b00001100;
        // pattern[29] = 8'b00000000;
        // pattern[30] = 8'b00001100;
        // pattern[31] = 8'b00000000;
        // 3 [20] -- does not work
        // pattern[0] = 8'b00000000;
        // pattern[1] = 8'b00000000;
        // pattern[2] = 8'b00000001;
        // pattern[3] = 8'b11100000;
        // pattern[4] = 8'b00000111;
        // pattern[5] = 8'b11110000;
        // pattern[6] = 8'b00001111;
        // pattern[7] = 8'b00110000;
        // pattern[8] = 8'b00001100;
        // pattern[9] = 8'b00000000;
        // pattern[10] = 8'b00001100;
        // pattern[11] = 8'b00000000;
        // pattern[12] = 8'b00001110;
        // pattern[13] = 8'b00000000;
        // pattern[14] = 8'b00001111;
        // pattern[15] = 8'b11110000;
        // pattern[16] = 8'b00000111;
        // pattern[17] = 8'b11110000;
        // pattern[18] = 8'b00000001;
        // pattern[19] = 8'b10000000;
        // pattern[20] = 8'b00000011;
        // pattern[21] = 8'b10110000;
        // pattern[22] = 8'b00000011;
        // pattern[23] = 8'b11110000;
        // pattern[24] = 8'b00000011;
        // pattern[25] = 8'b11110000;
        // pattern[26] = 8'b00000011;
        // pattern[27] = 8'b11000000;
        // pattern[28] = 8'b00000000;
        // pattern[29] = 8'b00000000;
        // pattern[30] = 8'b00000000;
        // pattern[31] = 8'b00000000;           
        // 9 [30]
    //     pattern[0] = 8'b00000001;
    //     pattern[1] = 8'b11000000;
    //     pattern[2] = 8'b00000001;
    //     pattern[3] = 8'b11000000;
    //     pattern[4] = 8'b00000001;
    //     pattern[5] = 8'b11000000;
    //     pattern[6] = 8'b00000011;
    //     pattern[7] = 8'b10000000;
    //     pattern[8] = 8'b00000011;
    //     pattern[9] = 8'b10000000;
    //     pattern[10] = 8'b00000111;
    //     pattern[11] = 8'b00000000;
    //     pattern[12] = 8'b00000111;
    //     pattern[13] = 8'b11100000;
    //     pattern[14] = 8'b00001111;
    //     pattern[15] = 8'b11110000;
    //     pattern[16] = 8'b00001111;
    //     pattern[17] = 8'b00111000;
    //     pattern[18] = 8'b00011100;
    //     pattern[19] = 8'b01110000;
    //     pattern[20] = 8'b00011111;
    //     pattern[21] = 8'b11110000;
    //     pattern[22] = 8'b00001111;
    //     pattern[23] = 8'b11100000;
    //     pattern[24] = 8'b00000111;
    //     pattern[25] = 8'b00000000;
    //     pattern[26] = 8'b00000000;
    //     pattern[27] = 8'b00000000;
    //     pattern[28] = 8'b00000000;
    //     pattern[29] = 8'b00000000;
    //     pattern[30] = 8'b00000000;
    //     pattern[31] = 8'b00000000;           
    // end



    reg [7:0] current_pattern_byte;
    reg [3:0] latched_index;

    reg [4:0] i;
    always @(posedge CLK) begin
        i <= i + 1;
        if (flip) begin
            current_pattern_byte <= pattern5[i];
        end
        else begin
            current_pattern_byte <= pattern9[i];
        end
        if (i == 3) latched_index <= index;
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
        .clk(CLK),
        .rst_n(BTN_N)
    );

    seven_segment seven_segment(
        .in(latched_index),
        .out(pmod_1b)
    );

    pmod_oled_demo oled (
        .clk(CLK),      // Expect ~12 MHz clock on pin 35
        .led_red_n(LED_RED_N),    // Red LED (active-low)
	    .led_blu_n(LED_BLU_N),    // 
        .sclk(SCLK),     // SPI clock to OLED
        .mosi(MOSI),     // SPI MOSI
        .cs(CS),       // SPI chip select (active-low)
        .dc(DC),       // OLED D/C (0=command, 1=data)
        .res(RES),      // OLED reset (active-low)
        .vbatc(VBATC),    // OLED VBAT control (active-low)
        .vddc(VDDC)      // OLED VDD  control (active-low)
    );

    // assign pmod_1a = ~{value[3:0], value[7:4]};

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
    output wire [6:0] out
);
    always @(*) begin
        case(in)           // GFEDCBA
        4'd0:       out = ~7'b0111111; // "0"  
        4'd1:       out = ~7'b0000110; // "1" 
        4'd2:       out = ~7'b1011011; // "2" 
        4'd3:       out = ~7'b0110000; // "3" 
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