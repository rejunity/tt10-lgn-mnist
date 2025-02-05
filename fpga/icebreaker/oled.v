module pmod_oled_demo (
    input  wire clk,      // Expect ~12 MHz clock on pin 35
    output reg  led_red_n,    // Red LED (active-low)
	output reg  led_blu_n,    // 
    output reg  sclk,     // SPI clock to OLED
    output reg  mosi,     // SPI mosi
    output reg  cs,       // SPI chip select (active-low)
    output reg  dc,       // OLED D/C (0=command, 1=data)
    output reg  res,      // OLED reset (active-low)
    output reg  vbatc,    // OLED VBAT control (active-low)
    output reg  vddc      // OLED VDD  control (active-low)
);

    //----------------------------------------------------------------
    // 1) Generate a ~1 Hz heartbeat on led_red_n to prove we have a clock
    //----------------------------------------------------------------
    //   - led_red_n is active-low, so drive it LOW to turn it ON, HIGH to turn it OFF.
    //   - We'll blink at 1 Hz: ~0.5s ON, ~0.5s OFF, using a 25-bit counter at ~12 MHz.
    //----------------------------------------------------------------
    reg [24:0] hb_counter = 0;

    always @(posedge clk) begin
        hb_counter <= hb_counter + 1;
        // We’ll tie led_red_n to the top bit of hb_counter
        // so half the time it’s 1 (LED off), half the time 0 (LED on).
        led_red_n <= hb_counter[24];  // '1' => off, '0' => on, toggles every ~1.4s if 12 MHz
    end

    // If you want exactly ~1 second toggle:
    //   At 12 MHz, 12,000,000 cycles = 1 second.
    //   You’d need a 24-bit or 25-bit counter and compare. 
    //   But for demonstration, this is enough to see blinking if the clock is alive.

    //----------------------------------------------------------------
    // 2) A big finite-state machine to power up the OLED in slow motion
    //----------------------------------------------------------------

    // We'll define big waits in *main-clock cycles*, e.g. 12 million ~ 1 second at 12 MHz
    localparam WAIT_100MS  = 1_200_000;   // ~100 ms  (12e6 * 0.1)
    localparam WAIT_20MS   =  240_000;    // ~20 ms
    localparam WAIT_1MS    =   12_000;    // ~1 ms

    // States
    localparam ST_IDLE         = 0;
    localparam ST_RESET_ASSERT = 1;  // drive res=0
    localparam ST_RESET_WAIT   = 2;  // wait a few ms
    localparam ST_RESET_DEASSERT=3;  // drive res=1
    localparam ST_POWERON_VDD  = 4;
    localparam ST_WAIT_VDD     = 5;
    localparam ST_CMD_DISPLAY_OFF = 6;
    localparam ST_INIT_SEQ     = 7;
    localparam ST_POWERON_VBAT = 8;
    localparam ST_WAIT_VBAT    = 9;
    localparam ST_CMD_DISPLAY_ON = 10;
    localparam ST_DONE         = 11;
	localparam ST_DRAW_SETUP   = 12;
	localparam ST_DRAW_LOOP    = 13;
	localparam ST_DRAW_END     = 14;

    reg [3:0] state = ST_IDLE;

    // We'll keep a main counter for waiting
    reg [31:0] wait_counter = 0;

    // We’ll store a small block of initialization commands in a local ROM:
    reg [7:0] init_cmds [0:19];
    initial begin
        // Common recommended SSD1306 init for 128x32 with internal charge pump
        init_cmds[ 0] = 8'hD5; // Display clock divide
        init_cmds[ 1] = 8'h80; //   suggested ratio
        init_cmds[ 2] = 8'hA8; // Multiplex ratio
        init_cmds[ 3] = 8'h1F; //   for 128x32
        init_cmds[ 4] = 8'hD3; // Display offset
        init_cmds[ 5] = 8'h00;
        init_cmds[ 6] = 8'h40; // Start line at 0
        init_cmds[ 7] = 8'h8D; // Charge pump
        init_cmds[ 8] = 8'h14; //   enable
        init_cmds[ 9] = 8'h20; // Memory mode
        init_cmds[10] = 8'h00; //   horizontal
        init_cmds[11] = 8'hA1; // segment re-map
        init_cmds[12] = 8'hC8; // COM scan direction
        init_cmds[13] = 8'hDA; // COM pins
        init_cmds[14] = 8'h02;
        init_cmds[15] = 8'h81; // contrast
        init_cmds[16] = 8'h8F;
        init_cmds[17] = 8'hD9; // pre-charge
        init_cmds[18] = 8'hF1;
        init_cmds[19] = 8'hDB; // VCOM detect
    end

    reg [4:0] init_index = 0;

    // A sub- finite state machine for sending commands one at a time
    reg [7:0] spi_byte;     // the byte to send
    reg       spi_is_cmd;   // 0=cmd, 1=data
    reg       spi_req;      // handshake to start sending
    wire      spi_busy;     // indicates we’re still shifting out
    wire      spi_done;     // one-shot when done

	//----------------------------------------------------------------
	// 2a) 16x16 pattern array (row, col); 0=off, 1=on
	//----------------------------------------------------------------
	reg pattern [0:15][0:31];
	initial begin
		// Number 5 [4]
        pattern[0][0] = 0; pattern[0][1] = 0; pattern[0][2] = 0; pattern[0][3] = 0; pattern[0][4] = 0; pattern[0][5] = 0; pattern[0][6] = 0; pattern[0][7] = 0; pattern[0][8] = 0; pattern[0][9] = 0; pattern[0][10] = 0; pattern[0][11] = 0; pattern[0][12] = 0; pattern[0][13] = 0; pattern[0][14] = 0; pattern[0][15] = 0; 
        pattern[1][0] = 0; pattern[1][1] = 0; pattern[1][2] = 0; pattern[1][3] = 0; pattern[1][4] = 0; pattern[1][5] = 0; pattern[1][6] = 0; pattern[1][7] = 0; pattern[1][8] = 0; pattern[1][9] = 0; pattern[1][10] = 0; pattern[1][11] = 0; pattern[1][12] = 0; pattern[1][13] = 0; pattern[1][14] = 0; pattern[1][15] = 0; 
        pattern[2][0] = 0; pattern[2][1] = 0; pattern[2][2] = 0; pattern[2][3] = 0; pattern[2][4] = 0; pattern[2][5] = 0; pattern[2][6] = 0; pattern[2][7] = 0; pattern[2][8] = 1; pattern[2][9] = 1; pattern[2][10] = 1; pattern[2][11] = 0; pattern[2][12] = 0; pattern[2][13] = 0; pattern[2][14] = 0; pattern[2][15] = 0; 
        pattern[3][0] = 0; pattern[3][1] = 0; pattern[3][2] = 0; pattern[3][3] = 0; pattern[3][4] = 1; pattern[3][5] = 1; pattern[3][6] = 1; pattern[3][7] = 1; pattern[3][8] = 1; pattern[3][9] = 1; pattern[3][10] = 1; pattern[3][11] = 1; pattern[3][12] = 0; pattern[3][13] = 0; pattern[3][14] = 0; pattern[3][15] = 0; 
        pattern[4][0] = 0; pattern[4][1] = 0; pattern[4][2] = 0; pattern[4][3] = 0; pattern[4][4] = 1; pattern[4][5] = 1; pattern[4][6] = 1; pattern[4][7] = 1; pattern[4][8] = 0; pattern[4][9] = 0; pattern[4][10] = 0; pattern[4][11] = 0; pattern[4][12] = 0; pattern[4][13] = 0; pattern[4][14] = 0; pattern[4][15] = 0; 
        pattern[5][0] = 0; pattern[5][1] = 0; pattern[5][2] = 0; pattern[5][3] = 0; pattern[5][4] = 1; pattern[5][5] = 1; pattern[5][6] = 0; pattern[5][7] = 0; pattern[5][8] = 0; pattern[5][9] = 0; pattern[5][10] = 0; pattern[5][11] = 0; pattern[5][12] = 0; pattern[5][13] = 0; pattern[5][14] = 0; pattern[5][15] = 0; 
        pattern[6][0] = 0; pattern[6][1] = 0; pattern[6][2] = 0; pattern[6][3] = 1; pattern[6][4] = 1; pattern[6][5] = 1; pattern[6][6] = 1; pattern[6][7] = 0; pattern[6][8] = 0; pattern[6][9] = 0; pattern[6][10] = 0; pattern[6][11] = 0; pattern[6][12] = 0; pattern[6][13] = 0; pattern[6][14] = 0; pattern[6][15] = 0; 
        pattern[7][0] = 0; pattern[7][1] = 0; pattern[7][2] = 0; pattern[7][3] = 1; pattern[7][4] = 1; pattern[7][5] = 1; pattern[7][6] = 1; pattern[7][7] = 1; pattern[7][8] = 1; pattern[7][9] = 1; pattern[7][10] = 1; pattern[7][11] = 1; pattern[7][12] = 0; pattern[7][13] = 0; pattern[7][14] = 0; pattern[7][15] = 0; 
        pattern[8][0] = 0; pattern[8][1] = 0; pattern[8][2] = 0; pattern[8][3] = 1; pattern[8][4] = 1; pattern[8][5] = 0; pattern[8][6] = 0; pattern[8][7] = 0; pattern[8][8] = 1; pattern[8][9] = 1; pattern[8][10] = 1; pattern[8][11] = 1; pattern[8][12] = 1; pattern[8][13] = 0; pattern[8][14] = 0; pattern[8][15] = 0; 
        pattern[9][0] = 0; pattern[9][1] = 0; pattern[9][2] = 0; pattern[9][3] = 0; pattern[9][4] = 0; pattern[9][5] = 0; pattern[9][6] = 0; pattern[9][7] = 0; pattern[9][8] = 0; pattern[9][9] = 0; pattern[9][10] = 0; pattern[9][11] = 0; pattern[9][12] = 1; pattern[9][13] = 1; pattern[9][14] = 0; pattern[9][15] = 0; 
        pattern[10][0] = 0; pattern[10][1] = 0; pattern[10][2] = 0; pattern[10][3] = 0; pattern[10][4] = 0; pattern[10][5] = 0; pattern[10][6] = 0; pattern[10][7] = 0; pattern[10][8] = 0; pattern[10][9] = 0; pattern[10][10] = 0; pattern[10][11] = 0; pattern[10][12] = 1; pattern[10][13] = 1; pattern[10][14] = 0; pattern[10][15] = 0; 
        pattern[11][0] = 0; pattern[11][1] = 0; pattern[11][2] = 0; pattern[11][3] = 0; pattern[11][4] = 0; pattern[11][5] = 0; pattern[11][6] = 0; pattern[11][7] = 0; pattern[11][8] = 0; pattern[11][9] = 0; pattern[11][10] = 1; pattern[11][11] = 1; pattern[11][12] = 1; pattern[11][13] = 1; pattern[11][14] = 0; pattern[11][15] = 0; 
        pattern[12][0] = 0; pattern[12][1] = 0; pattern[12][2] = 1; pattern[12][3] = 1; pattern[12][4] = 1; pattern[12][5] = 1; pattern[12][6] = 1; pattern[12][7] = 1; pattern[12][8] = 1; pattern[12][9] = 1; pattern[12][10] = 1; pattern[12][11] = 1; pattern[12][12] = 1; pattern[12][13] = 0; pattern[12][14] = 0; pattern[12][15] = 0; 
        pattern[13][0] = 0; pattern[13][1] = 0; pattern[13][2] = 0; pattern[13][3] = 1; pattern[13][4] = 1; pattern[13][5] = 1; pattern[13][6] = 1; pattern[13][7] = 1; pattern[13][8] = 1; pattern[13][9] = 1; pattern[13][10] = 1; pattern[13][11] = 0; pattern[13][12] = 0; pattern[13][13] = 0; pattern[13][14] = 0; pattern[13][15] = 0; 
        pattern[14][0] = 0; pattern[14][1] = 0; pattern[14][2] = 0; pattern[14][3] = 0; pattern[14][4] = 0; pattern[14][5] = 0; pattern[14][6] = 0; pattern[14][7] = 0; pattern[14][8] = 0; pattern[14][9] = 0; pattern[14][10] = 0; pattern[14][11] = 0; pattern[14][12] = 0; pattern[14][13] = 0; pattern[14][14] = 0; pattern[14][15] = 0; 
        pattern[15][0] = 0; pattern[15][1] = 0; pattern[15][2] = 0; pattern[15][3] = 0; pattern[15][4] = 0; pattern[15][5] = 0; pattern[15][6] = 0; pattern[15][7] = 0; pattern[15][8] = 0; pattern[15][9] = 0; pattern[15][10] = 0; pattern[15][11] = 0; pattern[15][12] = 0; pattern[15][13] = 0; pattern[15][14] = 0; pattern[15][15] = 0;         
		// Number 9 [30]
        pattern[0][16] = 0; pattern[0][17] = 0; pattern[0][18] = 0; pattern[0][19] = 0; pattern[0][20] = 0; pattern[0][21] = 0; pattern[0][22] = 0; pattern[0][23] = 0; pattern[0][24] = 0; pattern[0][25] = 0; pattern[0][26] = 0; pattern[0][27] = 0; pattern[0][28] = 0; pattern[0][29] = 0; pattern[0][30] = 0; pattern[0][31] = 0; 
        pattern[1][16] = 0; pattern[1][17] = 0; pattern[1][18] = 0; pattern[1][19] = 0; pattern[1][20] = 0; pattern[1][21] = 0; pattern[1][22] = 0; pattern[1][23] = 0; pattern[1][24] = 0; pattern[1][25] = 0; pattern[1][26] = 0; pattern[1][27] = 0; pattern[1][28] = 0; pattern[1][29] = 0; pattern[1][30] = 0; pattern[1][31] = 0; 
        pattern[2][16] = 0; pattern[2][17] = 0; pattern[2][18] = 0; pattern[2][19] = 0; pattern[2][20] = 0; pattern[2][21] = 0; pattern[2][22] = 0; pattern[2][23] = 0; pattern[2][24] = 0; pattern[2][25] = 0; pattern[2][26] = 0; pattern[2][27] = 0; pattern[2][28] = 0; pattern[2][29] = 0; pattern[2][30] = 0; pattern[2][31] = 0; 
        pattern[3][16] = 0; pattern[3][17] = 0; pattern[3][18] = 0; pattern[3][19] = 0; pattern[3][20] = 0; pattern[3][21] = 0; pattern[3][22] = 0; pattern[3][23] = 0; pattern[3][24] = 1; pattern[3][25] = 1; pattern[3][26] = 1; pattern[3][27] = 0; pattern[3][28] = 0; pattern[3][29] = 0; pattern[3][30] = 0; pattern[3][31] = 0; 
        pattern[4][16] = 0; pattern[4][17] = 0; pattern[4][18] = 0; pattern[4][19] = 0; pattern[4][20] = 0; pattern[4][21] = 1; pattern[4][22] = 1; pattern[4][23] = 1; pattern[4][24] = 1; pattern[4][25] = 1; pattern[4][26] = 1; pattern[4][27] = 1; pattern[4][28] = 0; pattern[4][29] = 0; pattern[4][30] = 0; pattern[4][31] = 0; 
        pattern[5][16] = 0; pattern[5][17] = 0; pattern[5][18] = 0; pattern[5][19] = 0; pattern[5][20] = 1; pattern[5][21] = 1; pattern[5][22] = 1; pattern[5][23] = 1; pattern[5][24] = 1; pattern[5][25] = 1; pattern[5][26] = 1; pattern[5][27] = 1; pattern[5][28] = 1; pattern[5][29] = 0; pattern[5][30] = 0; pattern[5][31] = 0; 
        pattern[6][16] = 0; pattern[6][17] = 0; pattern[6][18] = 0; pattern[6][19] = 0; pattern[6][20] = 1; pattern[6][21] = 1; pattern[6][22] = 1; pattern[6][23] = 0; pattern[6][24] = 0; pattern[6][25] = 0; pattern[6][26] = 1; pattern[6][27] = 1; pattern[6][28] = 1; pattern[6][29] = 0; pattern[6][30] = 0; pattern[6][31] = 0; 
        pattern[7][16] = 0; pattern[7][17] = 0; pattern[7][18] = 0; pattern[7][19] = 1; pattern[7][20] = 1; pattern[7][21] = 1; pattern[7][22] = 0; pattern[7][23] = 0; pattern[7][24] = 1; pattern[7][25] = 1; pattern[7][26] = 1; pattern[7][27] = 1; pattern[7][28] = 0; pattern[7][29] = 0; pattern[7][30] = 0; pattern[7][31] = 0; 
        pattern[8][16] = 0; pattern[8][17] = 0; pattern[8][18] = 0; pattern[8][19] = 0; pattern[8][20] = 1; pattern[8][21] = 1; pattern[8][22] = 1; pattern[8][23] = 1; pattern[8][24] = 1; pattern[8][25] = 1; pattern[8][26] = 1; pattern[8][27] = 1; pattern[8][28] = 0; pattern[8][29] = 0; pattern[8][30] = 0; pattern[8][31] = 0; 
        pattern[9][16] = 0; pattern[9][17] = 0; pattern[9][18] = 0; pattern[9][19] = 0; pattern[9][20] = 0; pattern[9][21] = 1; pattern[9][22] = 1; pattern[9][23] = 1; pattern[9][24] = 1; pattern[9][25] = 1; pattern[9][26] = 1; pattern[9][27] = 0; pattern[9][28] = 0; pattern[9][29] = 0; pattern[9][30] = 0; pattern[9][31] = 0; 
        pattern[10][16] = 0; pattern[10][17] = 0; pattern[10][18] = 0; pattern[10][19] = 0; pattern[10][20] = 0; pattern[10][21] = 0; pattern[10][22] = 0; pattern[10][23] = 0; pattern[10][24] = 1; pattern[10][25] = 1; pattern[10][26] = 1; pattern[10][27] = 0; pattern[10][28] = 0; pattern[10][29] = 0; pattern[10][30] = 0; pattern[10][31] = 0; 
        pattern[11][16] = 0; pattern[11][17] = 0; pattern[11][18] = 0; pattern[11][19] = 0; pattern[11][20] = 0; pattern[11][21] = 0; pattern[11][22] = 0; pattern[11][23] = 1; pattern[11][24] = 1; pattern[11][25] = 1; pattern[11][26] = 0; pattern[11][27] = 0; pattern[11][28] = 0; pattern[11][29] = 0; pattern[11][30] = 0; pattern[11][31] = 0; 
        pattern[12][16] = 0; pattern[12][17] = 0; pattern[12][18] = 0; pattern[12][19] = 0; pattern[12][20] = 0; pattern[12][21] = 0; pattern[12][22] = 0; pattern[12][23] = 1; pattern[12][24] = 1; pattern[12][25] = 1; pattern[12][26] = 0; pattern[12][27] = 0; pattern[12][28] = 0; pattern[12][29] = 0; pattern[12][30] = 0; pattern[12][31] = 0; 
        pattern[13][16] = 0; pattern[13][17] = 0; pattern[13][18] = 0; pattern[13][19] = 0; pattern[13][20] = 0; pattern[13][21] = 0; pattern[13][22] = 1; pattern[13][23] = 1; pattern[13][24] = 1; pattern[13][25] = 0; pattern[13][26] = 0; pattern[13][27] = 0; pattern[13][28] = 0; pattern[13][29] = 0; pattern[13][30] = 0; pattern[13][31] = 0; 
        pattern[14][16] = 0; pattern[14][17] = 0; pattern[14][18] = 0; pattern[14][19] = 0; pattern[14][20] = 0; pattern[14][21] = 0; pattern[14][22] = 1; pattern[14][23] = 1; pattern[14][24] = 1; pattern[14][25] = 0; pattern[14][26] = 0; pattern[14][27] = 0; pattern[14][28] = 0; pattern[14][29] = 0; pattern[14][30] = 0; pattern[14][31] = 0; 
        pattern[15][16] = 0; pattern[15][17] = 0; pattern[15][18] = 0; pattern[15][19] = 0; pattern[15][20] = 0; pattern[15][21] = 0; pattern[15][22] = 1; pattern[15][23] = 1; pattern[15][24] = 1; pattern[15][25] = 0; pattern[15][26] = 0; pattern[15][27] = 0; pattern[15][28] = 0; pattern[15][29] = 0; pattern[15][30] = 0; pattern[15][31] = 0;         
	end
	reg [4:0] col;
	reg       page;

    // We'll add a small array for the 'set column/page address' sequence
    reg [7:0] draw_setup_cmds [0:5];
    initial begin
        // 0x21 => set column address, [0..15]
        draw_setup_cmds[0] = 8'h21; 
        draw_setup_cmds[1] = 8'h00;
        draw_setup_cmds[2] = 8'h1F; // End column 31
        // 0x22 => set page address, [0..1]
        draw_setup_cmds[3] = 8'h22;
        draw_setup_cmds[4] = 8'h00;
        draw_setup_cmds[5] = 8'h01;
    end

    reg [2:0]  draw_setup_index = 0;
    reg [5:0]  draw_data_index  = 0; // goes 0..31
    reg [7:0]  data_byte;
    integer    row;

    // Let’s define a simpler “bit-bang” SPI submodule (below).
    // We’ll just feed it (spi_req, spi_byte, spi_is_cmd),
    // and it’ll raise (spi_busy) until the byte is sent. Then (spi_done) goes high one cycle.
    // This submodule always runs in the main clock domain but sends sclk pulses at a slower rate.

    // We’ll do the main state transitions only when spi_busy=0 and wait_counter=0, so we
    // ensure we’re not mid-transfer or mid-wait.

    // Outputs we set outside: dc, cs, mosi, sclk
    // The submodule will drive sclk, mosi, cs => we just take the signals from it.

    reg slow_spi_enable = 1;  // we always enable it (just a parameter pass)
    slow_spi_xfer #(
        .CLKDIV(8)  // can adjust for a safer slow sclk (2^8=256 => sclk ~12e6/256=46.9 kHz)
    ) spi_iface (
        .clk       (clk),
        .enable    (slow_spi_enable),
        // request
        .start     (spi_req),
        .is_data   (spi_is_cmd), // ironically named, but we’ll invert inside
        .datain    (spi_byte),
        // handshake out
        .busy      (spi_busy),
        .done      (spi_done),
        // actual SPI pins
        .spi_sclk  (sclk),
        .spi_mosi  (mosi),
        .spi_cs    (cs),
        .spi_dc    (dc)
    );

    //--------------------------
    // The main OLED init FSM
    //--------------------------
    always @(posedge clk) begin
        // Decrement wait_counter if >0
        if (wait_counter > 0)
            wait_counter <= wait_counter - 1;

        case (state)
        //--------------------------------------------------
        ST_IDLE: begin
            // Defaults: turn off both power lines (active-low => 1=OFF)
            vddc  <= 1;
            vbatc <= 1;
            res   <= 1;  // not in reset
            init_index <= 0;
            wait_counter <= 0;
            // Move on
            state <= ST_RESET_ASSERT;
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        // Give a real hardware reset pulse to the panel
        ST_RESET_ASSERT: begin
            res <= 0;  // drive reset low
            if (wait_counter == 0) begin
                wait_counter <= WAIT_20MS; // ~20 ms
                state <= ST_RESET_WAIT;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_RESET_WAIT: begin
            if (wait_counter == 0) begin
                // done waiting, release reset
                res <= 1;
                state <= ST_RESET_DEASSERT;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_RESET_DEASSERT: begin
            // Wait another 20ms after releasing reset
            wait_counter <= WAIT_20MS;
            state <= ST_POWERON_VDD;
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_POWERON_VDD: begin
            if (wait_counter == 0) begin
                // turn on logic power
                vddc <= 0; // active-low => 0 = ON
                // wait another 20ms
                wait_counter <= WAIT_20MS;
                state <= ST_WAIT_VDD;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_WAIT_VDD: begin
            if (wait_counter == 0) begin
                state <= ST_CMD_DISPLAY_OFF;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_CMD_DISPLAY_OFF: begin
            // Send 0xAE => display off
            if (!spi_busy && !spi_req) begin
                spi_byte  <= 8'hAE;
                spi_is_cmd <= 0;    // 0 => command
                spi_req   <= 1;     // request start
            end
            else if (spi_done) begin
                // after sending that command, proceed
                spi_req <= 0;
                // Wait ~1 ms after this command
                wait_counter <= WAIT_1MS;
                state <= ST_INIT_SEQ;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_INIT_SEQ: begin
            // We have 20 bytes in init_cmds, then we send the last param (0x00 after 0xDB).
            if (!spi_busy && !spi_req && wait_counter == 0) begin
                // Are we done with all 20 init_cmds?
                if (init_index < 20) begin
                    spi_byte  <= init_cmds[init_index];
                    spi_is_cmd <= 0;  // command
                    spi_req   <= 1;
                    init_index <= init_index + 1;
                end
                else if (init_index == 20) begin
                    // We must send the next param for the 0xDB command => 0x40
                    spi_byte  <= 8'h40;  // recommended ~0.77*Vcc
                    spi_is_cmd <= 0;
                    spi_req   <= 1;
                    init_index <= init_index + 1;
                end
                else begin
                    // done with init
                    state <= ST_POWERON_VBAT;
                end
            end
            else if (spi_done) begin
                // finishing a command, so release spi_req, wait ~1 ms before next
                spi_req <= 0;
                wait_counter <= WAIT_1MS;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_POWERON_VBAT: begin
            if (!spi_busy && !spi_req && wait_counter == 0) begin
                // turn on panel power
                vbatc <= 0; // active-low => 0=ON
                wait_counter <= WAIT_100MS; // recommended ~100 ms
                state <= ST_WAIT_VBAT;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        ST_WAIT_VBAT: begin
            if (wait_counter == 0) begin
                state <= ST_CMD_DISPLAY_ON;
            end
			led_blu_n <= ~1'b0; // off
        end

        //--------------------------------------------------
        // We move from ST_CMD_DISPLAY_ON -> ST_DRAW_SETUP
        //--------------------------------------------------
        ST_CMD_DISPLAY_ON: begin
            if (!spi_busy && !spi_req) begin
                spi_byte  <= 8'hAF; // display on
                spi_is_cmd <= 0;
                spi_req   <= 1;
            end
            else if (spi_done) begin
                spi_req <= 0;
                // next we configure column/page to cover 16x16 area
                draw_setup_index <= 0;
                state <= ST_DRAW_SETUP;
            end
        end

        //--------------------------------------------------
        // ST_DRAW_SETUP: send 6 bytes (0x21,0x00,0x0F,0x22,0x00,0x01)
        //--------------------------------------------------
        ST_DRAW_SETUP: begin
            if (!spi_busy && !spi_req) begin
                if (draw_setup_index < 6) begin
                    spi_byte  <= draw_setup_cmds[draw_setup_index];
                    spi_is_cmd <= 0; // command
                    spi_req   <= 1;
                    draw_setup_index <= draw_setup_index + 1;
                end else begin
                    // done setting col/page
                    draw_data_index <= 0;
                    state <= ST_DRAW_LOOP;
                end
            end
            else if (spi_done) begin
                spi_req <= 0;
            end
        end

		//--------------------------------------------------
		// ST_DRAW_LOOP: bit-pack the array and send 32 bytes
		//--------------------------------------------------
		ST_DRAW_LOOP: begin
		    if (!spi_busy && !spi_req) begin
		        // compute the page, col, and gather bits
		        // draw_data_index:  0..15 => page0, col0..15
		        //                  16..31 => page1, col0..15
				page = draw_data_index[5];   // bit 5 => page (0 or 1)
				col  = draw_data_index[4:0]; // bits 4..0 => column 0..31
		        data_byte = 8'h00;
		        for (row=0; row<8; row=row+1) begin
		            data_byte[row] = pattern[row + 8*page][col];
		        end
		
		        spi_byte  <= data_byte;
		        spi_is_cmd <= 1;  // 1 => data
		        spi_req   <= 1;
		    end
		    else if (spi_done) begin
		        spi_req <= 0;
		        draw_data_index <= draw_data_index + 1;
		        if (draw_data_index == 63) begin
		            state <= ST_DRAW_END;
		        end
		    end
		end

        ST_DRAW_END: begin
            // We have loaded all 32 bytes of the 16x16 block
            // Re-enter ST_DONE or remain here
            state <= ST_DONE;
        end

        //--------------------------------------------------
        ST_DONE: begin
			led_blu_n <= 1'b0; // stays on
            // We stay here forever, with the display presumably ON.
            // The heartbeat LED continues blinking, so you can see
            // the FPGA is alive. If the display is still dark,
            // check Pmod orientation, power lines, or damage.
        end

        endcase
    end

endmodule

//-----------------------------------------------------------------------
// Simple SPI bit-bang submodule that sends one byte at a slow sclk rate
//   - param .CLKDIV => 2^CLKDIV is the sclk divider from the main clock
//   - if .enable=1, we accept start requests
//   - .is_data=0 => dc=0 (command), is_data=1 => dc=1 (data)
//   - cs is driven LOW while shifting, then HIGH when done
//   - sclk is toggled in the sub-FSM
//-----------------------------------------------------------------------
module slow_spi_xfer #(
    parameter CLKDIV=8
) (
    input  wire clk,
    input  wire enable,
    input  wire start,
    input  wire is_data,   // 1 => dc=1 => data, 0 => command
    input  wire [7:0] datain,
    output reg  busy,
    output reg  done,      // 1-cycle pulse at completion

    output reg  spi_sclk,
    output reg  spi_mosi,
    output reg  spi_cs,    // active-low
    output reg  spi_dc
);

    // We’ll run a small FSM to shift out `datain` bit-by-bit at a slow sclk rate.
    // Steps:
    //  1) When start=1 and enable=1 and !busy, latch datain, is_data
    //  2) Lower spi_cs=0, set spi_dc = is_data
    //  3) shift out 8 bits on mosi, toggling sclk
    //  4) raise spi_cs=1, assert done for 1 cycle

    localparam S_IDLE     = 0;
    localparam S_LATCH    = 1;
    localparam S_SHIFTING = 2;
    localparam S_DONE     = 3;

    reg [1:0]  st = S_IDLE;
    reg [7:0]  shift_reg = 8'h00;
    reg [7:0]  clkdiv_cnt = 0;
    reg [2:0]  bitcount   = 0;

    always @(posedge clk) begin
        done <= 0;

        case (st)
        //-----------------------------------------
        S_IDLE: begin
            busy     <= 0;
            spi_cs   <= 1;   // not selected
            spi_sclk <= 0;
            spi_mosi <= 0;
            spi_dc   <= 0;   // default to command
            if (start && enable) begin
                st <= S_LATCH;
            end
        end
        //-----------------------------------------
        S_LATCH: begin
            // Latch the data, set dc according to is_data
            busy     <= 1;
            shift_reg<= datain;
            spi_dc   <= is_data; 
            // Lower cs to start
            spi_cs   <= 0;
            bitcount <= 7;
            clkdiv_cnt <= 0;
            spi_mosi <= datain[7]; // first bit
            st <= S_SHIFTING;
        end
        //-----------------------------------------
        S_SHIFTING: begin
            // We toggle sclk at a rate of clk/(2^(CLKDIV)). So we use clkdiv_cnt
            if (clkdiv_cnt == (1 << CLKDIV)-1) begin
                clkdiv_cnt <= 0;
                spi_sclk   <= ~spi_sclk;

                // On the falling edge of sclk, we shift out the next bit
                if (spi_sclk == 1) begin
                    // just had a rising edge, so next half-cycle is falling
                    // shift the register
                    shift_reg <= {shift_reg[6:0], 1'b0};
                    bitcount  <= bitcount - 1;
                    spi_mosi  <= shift_reg[6]; // next bit
                end

                // Once we have toggled sclk low after the last bit, we move on
                if (bitcount == 0 && spi_sclk == 1) begin
                    st <= S_DONE;
                end
            end else begin
                clkdiv_cnt <= clkdiv_cnt + 1;
            end
        end
        //-----------------------------------------
        S_DONE: begin
            // Return cs high, pulse done
            spi_cs <= 1;
            done   <= 1;
            // go back to IDLE
            st <= S_IDLE;
        end

        endcase
    end

endmodule