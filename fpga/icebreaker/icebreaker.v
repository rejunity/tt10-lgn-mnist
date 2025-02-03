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
    reg [7:0] pattern [0:31];
    initial begin
        pattern[0] = 8'b00000000;
        pattern[1] = 8'b00000000;
        pattern[2] = 8'b00000000;
        pattern[3] = 8'b00000000;
        pattern[4] = 8'b00000011;
        pattern[5] = 8'b11100000;
        pattern[6] = 8'b00000111;
        pattern[7] = 8'b11110000;
        pattern[8] = 8'b00000111;
        pattern[9] = 8'b00111000;
        pattern[10] = 8'b00001110;
        pattern[11] = 8'b00011000;
        pattern[12] = 8'b00001100;
        pattern[13] = 8'b00011000;
        pattern[14] = 8'b00001100;
        pattern[15] = 8'b00011000;
        pattern[16] = 8'b00001100;
        pattern[17] = 8'b00011000;
        pattern[18] = 8'b00011000;
        pattern[19] = 8'b00011000;
        pattern[20] = 8'b00011000;
        pattern[21] = 8'b00111000;
        pattern[22] = 8'b00001100;
        pattern[23] = 8'b01110000;
        pattern[24] = 8'b00001111;
        pattern[25] = 8'b11110000;
        pattern[26] = 8'b00000111;
        pattern[27] = 8'b11000000;
        pattern[28] = 8'b00000000;
        pattern[29] = 8'b00000000;
        pattern[30] = 8'b00000000;
        pattern[31] = 8'b00000000;
    end 



    reg [7:0] current_pattern_byte;
    reg [3:0] latched_index;

    reg [5:0] i;
    always @(posedge CLK) begin
        i <= i + 1;
        current_pattern_byte <= one_pattern[i];
        if (i == 16) latched_index <= index;
    end
    
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

    assign pmod_1a = ~{value[3:0], value[7:4]};

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