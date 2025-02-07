`default_nettype none

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

    output wire[7:0] pmod_1a,
    output wire[7:0] pmod_1b
);
    localparam IMAGE_COUNT = 480; // 480 images is maximum that fits in iCE40 UP5K FPGA
    localparam CYCLES_TO_WAIT_BETWEEN_IMAGES = 12*1000*1000 / 10;

    wire on_time;
    timer #(.CYCLES_TO_TRIGGER(CYCLES_TO_WAIT_BETWEEN_IMAGES),
            .SLOWDOWN_FACTOR(8)) timer (
        .clk    (CLK),
        .slow   (BTN1 || BTN2 || BTN3),
        .trigger(on_time),
        );

    localparam BYTES_PER_IMAGE = 16*2;
    reg [7:0] patterns[0:IMAGE_COUNT*BYTES_PER_IMAGE-1];
    initial begin
        $readmemb("../../src/test_images.mem", patterns);
    end

    reg [3:0] expected_digit;
    reg [$clog2(IMAGE_COUNT):0] image_counter;
    always @(posedge CLK) begin
        if (!failure && on_time) begin
            if (expected_digit != latched_index) begin
                failure <= 1;
            end else begin
                expected_digit <= expected_digit + 1;
                image_counter  <= image_counter + 1;
                if (expected_digit == 9) // decimal digits
                    expected_digit <= 0;
                if (image_counter == IMAGE_COUNT-1) begin
                    // reached the last image,
                    // restart image counters
                    expected_digit <= 0;
                    image_counter <= 0;
                    success = 1;
                end
            end
        end
    end

    // inference --------------------------------------------------------------
    wire slow_clk; // = CLK;
    clock_div2 clock_div2(
        .clk_12MHz(CLK),
        .clk_6MHz(slow_clk)
    );

    reg [7:0] loaded_data;
    reg [$clog2(BYTES_PER_IMAGE)-1:0] pattern_counter;
    always @(posedge slow_clk) loaded_data <= patterns[{image_counter, pattern_counter}];
    always @(posedge slow_clk) pattern_counter <= pattern_counter + 1'b1;
    
    localparam WE_ = 0;
    tt_um_rejunity_lgn_mnist mnist(
        .clk(slow_clk),
        .ui_in  (loaded_data),
        .uo_out (value),
        .uio_in ({WE_, 7'h00}),
        .uio_out(index),
        .uio_oe (),
        .ena    (1'b1),
        .rst_n  (BTN_N)
    );

    wire [3:0] index;
    wire [7:0] value;
    reg [3:0] latched_index;
    reg [7:0] latched_value;

    // latch the result of the inference on the 31+2 = 1
    localparam LATCH_INFERENCE_RESULTS_ON_CLK = 1;
    always @(posedge slow_clk) begin
        if (pattern_counter == LATCH_INFERENCE_RESULTS_ON_CLK) begin
            latched_index <= index;
            latched_value <= value;
        end
    end

    // display ----------------------------------------------------------------
    reg success = 0;
    reg failure = 0;
    reg blinker; always @(posedge CLK) if (on_time) blinker <= ~blinker;
    assign LED1 = failure && blinker;
    assign LED2 = success || blinker;
    assign {LED5, LED3, LED4} = {success, success, success};

    muselab_eight_led_strip value_lcd(
        .in(latched_value),
        .pmod(pmod_1a)
    );

    wire [3:0] predicted_digit_with_blink_on_failure = 
        (failure && blinker) ? 4'hF : latched_index;
    double_digit_seven_segment category_lcd(
        .clk(CLK),
        .left(expected_digit),
        .right(predicted_digit_with_blink_on_failure),
        .pmod(pmod_1b)
    );
endmodule

///////////////////////////////////////////////////////////////////////////////
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
        default:    out = ~7'b0000000; // "0"
        endcase
    end
endmodule

module double_digit_seven_segment (
    input  wire clk,
    input  wire [3:0] left,
    input  wire [3:0] right,
    output reg  [7:0] pmod
);
    reg tick_tock;
    always @(posedge clk) tick_tock <= ~tick_tock;
    seven_segment seven_segment(
        .in(tick_tock ? right : left),
        .out(pmod[6:0])
    );
    assign pmod[7] = tick_tock;
endmodule

// MuseLab PMOD-LED v1.x is funky connected for some reason
module muselab_eight_led_strip (
    input  wire [7:0] in,
    input  wire [7:0] pmod
);
    assign pmod = ~{in[3:0], in[7:4]};
endmodule

module timer #(
    parameter CYCLES_TO_TRIGGER = 12*1000*1000,
    parameter SLOWDOWN_FACTOR = 2,
) (
    input wire clk,
    input wire slow,
    output wire trigger
);
    localparam COUNTER_BITS = $clog2(CYCLES_TO_TRIGGER);
    localparam SLOWDOWN_BITS = $clog2(SLOWDOWN_FACTOR);
    reg [(COUNTER_BITS+SLOWDOWN_BITS):0] counter;
    always @(posedge clk) begin
        trigger <= 0;
        counter <= counter + 1;
        if (counter[slow*SLOWDOWN_BITS +: COUNTER_BITS] >= CYCLES_TO_TRIGGER) begin
            trigger <= 1;
            counter <= 0;
        end
    end
endmodule

///////////////////////////////////////////////////////////////////////////////
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
