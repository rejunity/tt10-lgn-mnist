import sys
import os
import numpy as np


# TODO: Inject additional pass-through (negate / or) gates on the long connections.
#       Use keep directive to avoid optimisastion by Yosys.

# def save(model, npz_fname):
#     gate_types = [torch.argmax(layer.w.data, dim=0) for layer in model.layers];
#     gate_types = torch.stack(gate_types, dim=0).cpu().numpy()
#     numpy_dict = {  "gate_types" : gate_types,
#                     "connections.A" : model.connections[0].cpu().numpy(),
#                     "connections.B" : model.connections[1].cpu().numpy() }
#     np.savez(npz_fname, **numpy_dict)

EXPANDED_VERILOG = False
# EXPANDED_VERILOG = True

MAX_LAYERS = -1

def load_npz_file(file_name):
    if not file_name.endswith('.npz'):
        raise ValueError(f"The file '{file_name}' is not a .npz file.")

    if not os.path.isfile(file_name):
        raise FileNotFoundError(f"The file '{file_name}' does not exist.")

    try:
        data = np.load(file_name)
        return data
    except Exception as e:
        raise RuntimeError(f"Failed to load the .npz file: {e}")

def op(gate_type, A, B):
    return [
        f"1'b0",
        f"{A} & {B}",
        f"{A} & ~{B}",
        f"{A}",
        f"{B} & ~{A}",
        f"{B}",
        f"{A} ^ {B}",
        f"{A} | {B}",
        f"~({A} | {B})",
        f"~({A} ^ {B})",
        f"~{B}",
        f"~{B} | ({A} & {B})",
        f"~{A}",
        f"~{A} | ({A} & {B})",
        f"~({A} & {B})",
        f"1'b1"
    ][gate_type]

def generate_verilog(npz_file_name, global_inputs, gates, conn_a, conn_b):
    global_outputs = len(gates[-1])

    decl = ""
    body = ""
    gate_idx = 0
    assert len(gates) == len(conn_a) == len(conn_b)
    if MAX_LAYERS > 0 and len(gates) > MAX_LAYERS:
        layers_to_cut = len(gates) - MAX_LAYERS
        print(f"Optional max_layers = {MAX_LAYERS} parameter was specified, cutting the last {layers_to_cut} layer(s)!")
        gates = gates[:-layers_to_cut]
        conn_a = conn_a[:-layers_to_cut]
        conn_b = conn_b[:-layers_to_cut]
        print(f"There are {len(gates)} layers after cut.")
    for layer_idx, layer_gates, layer_conn_a, layer_conn_b in zip(range(len(gates)), gates, conn_a, conn_b):
        if layer_idx > 0:
            decl += f"    wire [{len(gates[layer_idx-1])}:0] layer_{layer_idx-1};\n"
            input = f"layer_{layer_idx-1}"
        else:
            input = "in"

        if layer_idx < len(gates) - 1:
            output = f"layer_{layer_idx}"
        else:
            output = "out"

        assert len(layer_gates) == len(layer_conn_a) == len(layer_conn_b)
        body += f"    // Layer {layer_idx} ============================================================\n"
        if EXPANDED_VERILOG:
            for out_idx, gate, a, b in zip(range(len(layer_gates)), layer_gates, layer_conn_a, layer_conn_b):
                body += f"    logic_gate gate_{layer_idx}_{gate_idx} ("
                body += f"        .A({input}[{a}]),"
                body += f"        .B({input}[{b}]),"
                body += f"        .gate_type(4'd{gate}),"
                body += f"        .Y({output}[{out_idx}])"
                body += f"    );\n"
                gate_idx += 1
        else:
            for out_idx, gate, a, b in zip(range(len(layer_gates)), layer_gates, layer_conn_a, layer_conn_b):
                body += f"    assign {output}[{out_idx}] = {op(gate, f'{input}[{a}]', f'{input}[{b}]')}; \n"
                gate_idx += 1

    verilog = f"// Generated from: {npz_file_name}"
    if EXPANDED_VERILOG:
        verilog += f"""
module logic_gate (
    input wire A,
    input wire B,
    input wire [3:0] gate_type,  // 4-bit gate type identifier
    output reg Y
);
    always @(*) begin
        case (gate_type)
            4'd0:  Y = 0;                          // g0:  0
            4'd1:  Y = A & B;                      // g1:  A * B
            4'd2:  Y = A & ~B;                     // g2:  A - A * B
            4'd3:  Y = A;                          // g3:  A
            4'd4:  Y = B & ~A;                     // g4:  B - A * B
            4'd5:  Y = B;                          // g5:  B
            4'd6:  Y = A ^ B;                      // g6:  A + B - 2 * A * B
            4'd7:  Y = A | B;                      // g7:  A + B - A * B
            4'd8:  Y = ~(A | B);                   // g8:  1 - (A + B - A * B)
            4'd9:  Y = ~(A ^ B);                   // g9:  1 - (A + B - 2 * A * B)
            4'd10: Y = ~B;                         // g10: 1 - B
            4'd11: Y = ~B | (A & B);               // g11: 1 - B + A * B
            4'd12: Y = ~A;                         // g12: 1 - A
            4'd13: Y = ~A | (A & B);               // g13: 1 - A + A * B
            4'd14: Y = ~(A & B);                   // g14: 1 - A * B
            4'd15: Y = 1;                          // g15: 1
            default: Y = 0;                        // Default case
        endcase
    end
endmodule """
    else:
        verilog += f"""
module net (
    input wire  [{ global_inputs-1}:0] in,
    output wire [{global_outputs-1}:0] out
);
{decl}
{body}
endmodule
"""
    return verilog

def ascii_graph(values):
    # Array of characters for tiny histograms
    histogram_chars = np.array([
        " ","▁","▂","▃","▄","▅","▆","▇","▒","▓","█" 
    ])
    percentages = (values / values.sum()) * 100  # Normalize to 100%
    indices = (values * (len(histogram_chars) - 2)) // values.sum() + 1
    indices[percentages < 1] = 0
    return "".join(histogram_chars[indices]), percentages

def ascii_histogram(values, bins=16):
    values = np.hstack([values, np.arange(bins)])
    counts, _ = np.histogram(values, bins=bins)
    return ascii_graph(counts)

def ascii_histogram_compressed(values, bins=64):
    values = np.hstack([values, 0, 1])
    values[values >= np.mean(values) * 2] = np.mean(values) * 2
    if bins > np.max(values):
        bins = np.max(values) + 1
    counts, _ = np.histogram(values, bins=bins)
    # print(len(counts), bins, np.max(values))
    counts = np.pad(counts, bins-len(counts))
    # print(counts)
    # print(len(counts))
    return ascii_graph(counts)

###########################################################################################

if __name__ == "__main__":
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print("Usage: python load_npz_file.py <input_npz_file_name> <output_verilog_file_name> (optional: <max_layers>)")
        sys.exit(1)

    npz_file_name = sys.argv[1]
    if len(sys.argv) == 3:
        verilog_file_name = sys.argv[2]
    else:
        verilog_file_name = os.path.splitext(npz_file_name)[0] + ".v"
    if len(sys.argv) > 3:
        MAX_LAYERS = int(sys.argv[3])

    try:
        data = load_npz_file(npz_file_name)
        print("File loaded successfully.")
        print("Contents:")
        for key in data.keys():
            print(f"{key}: {data[key].shape}, dtype={data[key].dtype}")
    except Exception as e:
        print(f"Error: {e}")

    gates = data['gate_types']
    conn_a = data['connections.A']
    conn_b = data['connections.B']

    # for c, a, b in zip(np.abs(conn_b - conn_a), conn_b, conn_a):
    #     print(c, np.max(c), np.mean(c), np.median(c), ascii_histogram(c)[0])

    # inject input connections, if the first connectivity layer is missing
    assert len(conn_a) == len(conn_b)
    if (gates.shape[0] > conn_a.shape[0]):
        conn_a = np.vstack((np.zeros(len(gates[0]), dtype=conn_a.dtype), conn_a))
        conn_b = np.vstack((np.ones (len(gates[0]), dtype=conn_b.dtype), conn_b))
    input_count = np.max([np.max(conn_a[0,:]), np.max(conn_b[0,:])]) + 1

    print()
    print("Layer statistics:")
    print("   ","  _ _   ___ _ _ ")
    print("   ","0&⇒A⇐B⊕||⊕B⇐A⇒&1","   ","0...4..........16..............32.... connection distance .....>64")
    conn_distance = np.abs(conn_b - conn_a)
    for i, g, d in zip(range(len(gates)), gates, conn_distance):
        print(f"{i:3}", ascii_histogram(g)[0], "   ", ascii_histogram_compressed(d)[0])
        # print(d)
    print("   ","0&⇒A⇐B⊕||⊕B⇐A⇒&1")


    verilog = generate_verilog(npz_file_name, input_count, gates, conn_a, conn_b)

    with open(verilog_file_name, "w") as f:
        f.write(verilog)
    print(f"Verilog code has been generated and saved to '{verilog_file_name}'.")
