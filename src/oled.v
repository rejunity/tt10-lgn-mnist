// Parts of code adapted from
// https://github.com/lushaylabs/tangnano9k-series-examples/blob/10ab3c194f3a9fad9ff2963740d7efdd3ef80634/screen/screen.v

`default_nettype none

module oled_screen_128x32
// Digilent PB 200-222 Pmod OLED
#(
  parameter STARTUP_WAIT = 32'd12_000_000
)
(
    input clk,
    output io_sclk,
    output io_sdin,
    output io_cs,
    output io_dc,
    output io_reset
);

    // helpers for laying out 2D arrays on the OLED display
    reg [9:0] digitPixelCounter = 0;
    wire [2:0] blockIndex = digitPixelCounter[5:3];
    wire [2:0] bitIndex   = 7 - digitPixelCounter[2:0];
    reg [4:0] addressSet [0:7][0:3];  // 8 blocks x 4 addresses each
    initial begin
        addressSet[0][0] = 5'd6;  addressSet[0][1] = 5'd4;  addressSet[0][2] = 5'd2;  addressSet[0][3] = 5'd0;
        addressSet[1][0] = 5'd7;  addressSet[1][1] = 5'd5;  addressSet[1][2] = 5'd3;  addressSet[1][3] = 5'd1;
        addressSet[2][0] = 5'd14; addressSet[2][1] = 5'd12; addressSet[2][2] = 5'd10; addressSet[2][3] = 5'd8;
        addressSet[3][0] = 5'd15; addressSet[3][1] = 5'd13; addressSet[3][2] = 5'd11; addressSet[3][3] = 5'd9;
        addressSet[4][0] = 5'd22; addressSet[4][1] = 5'd20; addressSet[4][2] = 5'd18; addressSet[4][3] = 5'd16;
        addressSet[5][0] = 5'd23; addressSet[5][1] = 5'd21; addressSet[5][2] = 5'd19; addressSet[5][3] = 5'd17;
        addressSet[6][0] = 5'd30; addressSet[6][1] = 5'd28; addressSet[6][2] = 5'd26; addressSet[6][3] = 5'd24;
        addressSet[7][0] = 5'd31; addressSet[7][1] = 5'd29; addressSet[7][2] = 5'd27; addressSet[7][3] = 5'd25;
    end    

//   reg [7:0] patternTest[0:31];
//   initial begin
//       // test
//       patternTest[5'd00] = 8'b00000011; patternTest[5'd01] = 8'b11000000;
//       patternTest[5'd02] = 8'b00000001; patternTest[5'd03] = 8'b10000000;
//       patternTest[5'd04] = 8'b10000000; patternTest[5'd05] = 8'b00000001;
//       patternTest[5'd06] = 8'b11000000; patternTest[5'd07] = 8'b00000011;
      
//       patternTest[5'd08] = 8'b00000011; patternTest[5'd09] = 8'b11000000;
//       patternTest[5'd10] = 8'b00010001; patternTest[5'd11] = 8'b10000000;
//       patternTest[5'd12] = 8'b10000000; patternTest[5'd13] = 8'b00010001;
//       patternTest[5'd14] = 8'b11000000; patternTest[5'd15] = 8'b00000011;

//       patternTest[5'd16] = 8'b00000011; patternTest[5'd17] = 8'b11000000;
//       patternTest[5'd18] = 8'b00111001; patternTest[5'd19] = 8'b10000000;
//       patternTest[5'd20] = 8'b10000000; patternTest[5'd21] = 8'b00111001;
//       patternTest[5'd22] = 8'b11000000; patternTest[5'd23] = 8'b00000011;

//       patternTest[5'd24] = 8'b00000011; patternTest[5'd25] = 8'b11000000;
//       patternTest[5'd26] = 8'b01111101; patternTest[5'd27] = 8'b10000000;
//       patternTest[5'd28] = 8'b10000000; patternTest[5'd29] = 8'b01111101;
//       patternTest[5'd30] = 8'b11000000; patternTest[5'd31] = 8'b00000011;
//   end
  reg [7:0] pattern3[0:31];
  initial begin
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
  end


  reg [7:0] pattern5[0:31];
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
  end

  localparam STATE_INIT_POWER = 8'd0;
  localparam STATE_LOAD_INIT_CMD = 8'd1;
  localparam STATE_SEND = 8'd2;
  localparam STATE_CHECK_FINISHED_INIT = 8'd3;
  localparam STATE_LOAD_DATA = 8'd4;

  reg [32:0] counter = 0;
  reg [32:0] pattern_counter = 0;
  reg [2:0] state = 0;

  reg dc = 1;
  reg sclk = 1;
  reg sdin = 0;
  reg reset = 1;
  reg cs = 0;


  reg [7:0] dataToSend = 0;
  reg [3:0] bitNumber = 0;  
  reg [9:0] pixelCounter = 0;

  localparam SETUP_INSTRUCTIONS = 23;
  reg [(SETUP_INSTRUCTIONS*8)-1:0] startupCommands = {
    8'hAE,  // display off

    8'h81,  // contast value to 0x7F according to datasheet
    8'h7F,  

    8'hA6,  // normal screen mode (not inverted)

    8'h20,  // horizontal addressing mode
    8'h00,  

    8'hC8,  // normal scan direction

    8'h40,  // first line to start scanning from

    8'hA1,  // address 0 is segment 0

    8'hA8,  // mux ratio
    8'h3f,  // 63 (64 -1)

    8'hD3,  // display offset
    8'h00,  // no offset

    8'hD5,  // clock divide ratio
    8'h80,  // set to default ratio/osc frequency

    8'hD9,  // set precharge
    8'h22,  // switch precharge to 0x22 default

    8'hDB,  // vcom deselect level
    8'h20,  //  0x20 

    8'h8D,  // charge pump config
    8'h14,  // enable charge pump

    8'hA4,  // resume RAM content

    8'hAF   // display on
  };
  reg [7:0] commandIndex = SETUP_INSTRUCTIONS * 8;

  assign io_sclk = sclk;
  assign io_sdin = sdin;
  assign io_dc = dc;
  assign io_reset = reset;
  assign io_cs = cs;

  always @(posedge clk) begin
    case (state)
      STATE_INIT_POWER: begin
        counter <= counter + 1;
        if (counter < STARTUP_WAIT) begin
          reset <= 1;
        end
        else if (counter < STARTUP_WAIT * 2) begin
          reset <= 0;
        end
        else if (counter < STARTUP_WAIT * 3) begin
          reset <= 1;
        end
        else begin
          state <= STATE_LOAD_INIT_CMD;
          counter <= 32'b0;
        end
      end
      STATE_LOAD_INIT_CMD: begin
        dc <= 0;
        dataToSend <= startupCommands[(commandIndex-1)-:8'd8];
        state <= STATE_SEND;
        bitNumber <= 3'd7;
        cs <= 0;
        commandIndex <= commandIndex - 8'd8;
      end
      STATE_SEND: begin
        if (counter == 32'd0) begin
          sclk <= 0;
          sdin <= dataToSend[bitNumber];
          counter <= 32'd1;
        end
        else begin
          counter <= 32'd0;
          sclk <= 1;
          if (bitNumber == 0)
            state <= STATE_CHECK_FINISHED_INIT;
          else
            bitNumber <= bitNumber - 1;
        end
      end
      STATE_CHECK_FINISHED_INIT: begin
          cs <= 1;
          if (commandIndex == 0)
            state <= STATE_LOAD_DATA; 
          else
            state <= STATE_LOAD_INIT_CMD; 
      end
      STATE_LOAD_DATA: begin
        pixelCounter <= pixelCounter + 1;
        cs <= 0;
        dc <= 1;
        bitNumber <= 3'd7;
        state <= STATE_SEND;
        if (pixelCounter == 1023) begin
            digitPixelCounter <= 0;
            // dataToSend <= 0;
        end
        if (pixelCounter == 511) begin
            digitPixelCounter <= 0;
        //     dataToSend <= 0;
        end
        if ((pixelCounter < 512) & (pixelCounter % 128) < 16) begin
            if (digitPixelCounter < 64)
                dataToSend <= {
                    pattern5[addressSet[blockIndex][0]][bitIndex], pattern5[addressSet[blockIndex][0]][bitIndex],
                    pattern5[addressSet[blockIndex][1]][bitIndex], pattern5[addressSet[blockIndex][1]][bitIndex],
                    pattern5[addressSet[blockIndex][2]][bitIndex], pattern5[addressSet[blockIndex][2]][bitIndex],
                    pattern5[addressSet[blockIndex][3]][bitIndex], pattern5[addressSet[blockIndex][3]][bitIndex]
                };
            else
                dataToSend <= 0;
            digitPixelCounter <= digitPixelCounter + 1;
        end
        else if ((pixelCounter % 128) < 16) begin
            if (digitPixelCounter < 64)
                dataToSend <= {
                    pattern3[addressSet[blockIndex][0]][bitIndex], pattern3[addressSet[blockIndex][0]][bitIndex],
                    pattern3[addressSet[blockIndex][1]][bitIndex], pattern3[addressSet[blockIndex][1]][bitIndex],
                    pattern3[addressSet[blockIndex][2]][bitIndex], pattern3[addressSet[blockIndex][2]][bitIndex],
                    pattern3[addressSet[blockIndex][3]][bitIndex], pattern3[addressSet[blockIndex][3]][bitIndex]
                };
            else
                dataToSend <= 0;
            digitPixelCounter <= digitPixelCounter + 1;
        end
        else
            dataToSend <= 0;
    end
    endcase
  end

endmodule