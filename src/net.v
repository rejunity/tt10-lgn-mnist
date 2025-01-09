
module net (
    input wire  [1:0] in,
    output wire [14:0] out
);
    wire [15:0] layer_0;
    wire [15:0] layer_1;
    wire [15:0] layer_2;

    // Layer 0 ============================================================
    assign layer_0[0] = in[0]; 
    assign layer_0[1] = in[0] & ~in[1]; 
    assign layer_0[2] = in[0] & in[1]; 
    assign layer_0[3] = in[0]; 
    assign layer_0[4] = in[0] & in[1]; 
    assign layer_0[5] = in[0] | in[1]; 
    assign layer_0[6] = in[0] ^ in[1]; 
    assign layer_0[7] = in[0]; 
    assign layer_0[8] = ~(in[0] ^ in[1]); 
    assign layer_0[9] = in[0] & in[1]; 
    assign layer_0[10] = in[0]; 
    assign layer_0[11] = in[0]; 
    assign layer_0[12] = in[0]; 
    assign layer_0[13] = in[0]; 
    assign layer_0[14] = in[1]; 
    // Layer 1 ============================================================
    assign layer_1[0] = layer_0[12]; 
    assign layer_1[1] = layer_0[2]; 
    assign layer_1[2] = layer_0[1]; 
    assign layer_1[3] = layer_0[4]; 
    assign layer_1[4] = layer_0[6]; 
    assign layer_1[5] = layer_0[5]; 
    assign layer_1[6] = layer_0[10]; 
    assign layer_1[7] = layer_0[14]; 
    assign layer_1[8] = layer_0[10]; 
    assign layer_1[9] = layer_0[8]; 
    assign layer_1[10] = layer_0[13]; 
    assign layer_1[11] = layer_0[4]; 
    assign layer_1[12] = layer_0[5]; 
    assign layer_1[13] = layer_0[9]; 
    assign layer_1[14] = ~layer_0[3] | (layer_0[6] & layer_0[3]); 
    // Layer 2 ============================================================
    assign layer_2[0] = layer_1[7]; 
    assign layer_2[1] = layer_1[5]; 
    assign layer_2[2] = layer_1[10]; 
    assign layer_2[3] = layer_1[12]; 
    assign layer_2[4] = layer_1[1]; 
    assign layer_2[5] = layer_1[4] | layer_1[11]; 
    assign layer_2[6] = layer_1[11]; 
    assign layer_2[7] = layer_1[10]; 
    assign layer_2[8] = layer_1[11] & layer_1[1]; 
    assign layer_2[9] = ~layer_1[1] | (layer_1[14] & layer_1[1]); 
    assign layer_2[10] = layer_1[13]; 
    assign layer_2[11] = ~layer_1[9]; 
    assign layer_2[12] = layer_1[9]; 
    assign layer_2[13] = layer_1[7]; 
    assign layer_2[14] = layer_1[4]; 
    // Layer 3 ============================================================
    assign out[0] = layer_2[12]; 
    assign out[1] = layer_2[0]; 
    assign out[2] = layer_2[10]; 
    assign out[3] = layer_2[4] & layer_2[8]; 
    assign out[4] = layer_2[8]; 
    assign out[5] = layer_2[9]; 
    assign out[6] = layer_2[14]; 
    assign out[7] = layer_2[11]; 
    assign out[8] = layer_2[7] | layer_2[3]; 
    assign out[9] = layer_2[0] ^ layer_2[7]; 
    assign out[10] = ~(layer_2[11] | layer_2[5]); 
    assign out[11] = layer_2[12] & ~layer_2[4]; 
    assign out[12] = ~layer_2[3]; 
    assign out[13] = layer_2[9] & ~layer_2[5]; 
    assign out[14] = layer_2[12] & ~layer_2[13]; 

endmodule
