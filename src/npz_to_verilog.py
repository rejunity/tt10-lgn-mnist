import sys
import os
import numpy as np
from collections.abc import Sequence, Mapping

# DONE: Inject additional pass-through (negate / or) gates on the long connections.
#       Use keep directive to avoid optimisastion by Yosys.

# TODO: * %Warning-UNUSEDSIGNAL / predict gate count
#       * Fanout historgram
#       * Predict wire length 

EXPANDED_VERILOG = False
# EXPANDED_VERILOG = True

RELAY_LONG_CONNECTIONS = False
# RELAY_LONG_CONNECTIONS = 64

# ASSUME_CIRCULAR_LAYOUT_FOR_CONNECTION_LENGTH = False
ASSUME_CIRCULAR_LAYOUT_FOR_CONNECTION_LENGTH = True

# FORCE_TO_POWER_LAW = [.6, 0.2]
# FORCE_TO_POWER_LAW = [.55, 0.1]
# FORCE_TO_POWER_LAW = .5

NUMBER_OF_CATEGORIES = 10
OUTPUT_BITS_PER_CATEGORY = 255

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

def generate_verilog(global_inputs, gates, conn_a, conn_b, number_of_categories=NUMBER_OF_CATEGORIES, output_bits_per_category=OUTPUT_BITS_PER_CATEGORY):
    assert len(gates) == len(conn_a) == len(conn_b)
    global_outputs = len(gates[-1])

    decl = ""
    body = ""
    gate_idx = 0
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

        idx = 0
        def setup_inputs(body, layer_idx, gate_idx, a, b):
            input_a = f"{input}[{a}]"
            input_b = f"{input}[{b}]"
            if RELAY_LONG_CONNECTIONS > 0:
                relay_count = abs(b - a) // RELAY_LONG_CONNECTIONS
                for n in range(relay_count):
                    relay = f"far_{layer_idx}_{gate_idx}_{n}"
                    # body += f"    wire [1:0] {relay};"
                    # body += f"    relay_conn {relay}_a(.in({input_a}), .out({relay}[0]));"
                    # body += f"    relay_conn {relay}_b(.in({input_b}), .out({relay}[1]));"
                    # body += "\n"
                    # input_a = f"{relay}[0]"
                    # input_b = f"{relay}[1]"

                    body += f"    wire {relay};"
                    body += f"    relay_conn {relay}_b(.in({input_b}), .out({relay}));"
                    body += "\n"
                    input_b = f"{relay}"

            return body, input_a, input_b

        if EXPANDED_VERILOG:
            for out_idx, gate, a, b in zip(range(len(layer_gates)), layer_gates, layer_conn_a, layer_conn_b):
                body, input_a, input_b = setup_inputs(body, layer_idx, gate_idx, a, b)
                body += f"    logic_gate gate_{layer_idx}_{gate_idx} ("
                body += f"        .A({input_a}),"
                body += f"        .B({input_b}),"
                body += f"        .gate_type(4'd{gate}),"
                body += f"        .Y({output}[{out_idx}])"
                body += f"    );\n"
                gate_idx += 1
        else:
            for out_idx, gate, a, b in zip(range(len(layer_gates)), layer_gates, layer_conn_a, layer_conn_b):
                body, input_a, input_b = setup_inputs(body, layer_idx, gate_idx, a, b)
                body += f"    assign {output}[{out_idx}] = {op(gate, f'{input_a}', f'{input_b}')}; \n"
                gate_idx += 1

    if number_of_categories > 0:
        body += f"    // Arrange outputs in categories ================================================\n"
        out_wires_per_category = global_outputs // number_of_categories
        for i in range(number_of_categories):
            out_lo = i * out_wires_per_category
            cat_lo = i * output_bits_per_category
            out_hi = out_lo + min(out_wires_per_category, output_bits_per_category) - 1
            cat_hi = cat_lo + min(out_wires_per_category, output_bits_per_category) - 1
            body += f"    assign categories[{cat_hi}:{cat_lo}] = out[{out_hi}:{out_lo}];\n"

            if (output_bits_per_category > out_wires_per_category):
                cat_full = cat_lo + output_bits_per_category - 1
                body += f"    assign categories[{cat_full}:{cat_hi + 1}] = 0;\n"

    verilog = ""
    if RELAY_LONG_CONNECTIONS > 0:
        verilog += f"""
`ifdef SIM
module sky130_fd_sc_hd__inv_1 (
    input wire A,
    output wire Y
);
    assign Y = ~A;
endmodule
`endif
module relay_conn (
    input wire in,
    output wire out
);
    wire tmp;
    /* verilator lint_off PINMISSING */
    // https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/inv/README.html
    (* keep = "true" *) sky130_fd_sc_hd__inv_1 inv_a ( .Y(tmp), .A(in)  );
    // (* keep = "true" *) sky130_fd_sc_hd__inv_1 inv_b ( .Y(out), .A(tmp) );
    assign out = ~tmp; // allow the second inverter to be optimized
    /* verilator lint_on PINMISSING */
endmodule """

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
    input  wire [{ global_inputs-1}:0] in,
    output wire [{global_outputs-1}:0] out{"," if number_of_categories > 0 else ""}
    output wire [{number_of_categories*output_bits_per_category-1}:0] categories
);
{decl}
{body}
endmodule
"""
    return verilog

def additional_meta_info():
    try:
        return f"RANDOMIZED connections with power exponent: {FORCE_TO_POWER_LAW}"
    except:
        return ""

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
    counts = np.pad(counts, bins-len(counts))
    return ascii_graph(counts)

def load_npz_file(file_name):
    if not file_name.endswith('.npz'):
        raise ValueError(f"The file '{file_name}' is not a .npz file.")

    if not os.path.isfile(file_name):
        raise FileNotFoundError(f"The file '{file_name}' does not exist.")

    try:
        data = np.load(file_name)
        print("File loaded successfully.")
        print("Contents:")
        for key in data.keys():
            print(f"{key}: {data[key].shape}, dtype={data[key].dtype}")
        return data
    except Exception as e:
        raise RuntimeError(f"Failed to load the .npz file: {e}")

def save_verilog_file(file_name, verilog):
    with open(file_name, "w") as f:
        f.write(verilog)

#--- CORE function ------------------------------------------------------------------------

def npz_to_verilog(data, max_layers=-1):
    gates = data['gate_types']
    conn_a = data['connections.A']
    conn_b = data['connections.B']

    if 'inputs' in data:
        inputs = data['inputs'].dim(-1)
    else:
        inputs = max(np.max(conn_a[0]), np.max(conn_b[0]))
    inputs = [inputs] + [len(g) for g in gates]

    try:
        print(f"OVER-WRITING conections with random distributed according to power exponent: {FORCE_TO_POWER_LAW}")
        assert conn_a.shape == conn_b.shape
        for i in range(len(conn_a)):
            try:
                idx = min(i, len(FORCE_TO_POWER_LAW)-1)
                alpha = FORCE_TO_POWER_LAW[idx]
            except:
                alpha = FORCE_TO_POWER_LAW
            size = len(conn_a[i])
            zipf_floats = np.pow(np.arange(1, inputs[i] + 1), -alpha)
            zipf_probs = zipf_floats / zipf_floats.sum()  # Normalize
            # print(zipf_probs)
            def wire_stats(conn_a, conn_b, in_count):
                d = np.abs(conn_a - conn_b)
                if ASSUME_CIRCULAR_LAYOUT_FOR_CONNECTION_LENGTH:
                    d[d > in_count // 2] = in_count - d[d > in_count // 2]
                return np.max(d), np.mean(d)
            wire_before = wire_stats(conn_a[i], conn_b[i], inputs[i])
            conn_a[i] = np.random.choice(inputs[i]-1,     size=size)
            conn_b[i] = np.random.choice(len(zipf_probs), size=size, p=zipf_probs) + conn_a[i]
            conn_b[i][conn_b[i] >= inputs[i]] -= inputs[i]
            wire_after  = wire_stats(conn_a[i], conn_b[i], inputs[i])
            print(f"longest/average before: {int(wire_before[0])}/{int(wire_before[1])} vs now: {int(wire_after[0])}/{int(wire_after[1])}")
    except:
        pass

    # inject input connections, if the first connectivity layer is missing
    assert len(conn_a) == len(conn_b)
    if (gates.shape[0] > conn_a.shape[0]):
        conn_a = np.vstack((np.zeros(len(gates[0]), dtype=conn_a.dtype), conn_a))
        conn_b = np.vstack((np.ones (len(gates[0]), dtype=conn_b.dtype), conn_b))

    # (optional) cut layers above max_layers
    assert len(gates) == len(conn_a) == len(conn_b)
    if max_layers > 0 and len(gates) > max_layers:
        layers_to_cut = len(gates) - max_layers
        print(f"Optional max_layers = {max_layers} parameter was specified, cutting the last {layers_to_cut} layer(s)!")
        gates = gates[:-layers_to_cut]
        conn_a = conn_a[:-layers_to_cut]
        conn_b = conn_b[:-layers_to_cut]
        print(f"There are {len(gates)} layers after cut.")

    print()
    print("Layer statistics:")
    print("   ","  _ _   ___ _ _ ")
    print("   ","0&⇒A⇐B⊕||⊕B⇐A⇒&1","   ","0...4..........16..............32.... connection distance .....>64")
    total_wire = 0
    total_gates = np.prod(gates.shape)
    conn_distance = np.abs(conn_b - conn_a)
    for i, g, d, x in zip(range(len(gates)), gates, conn_distance, inputs):
        if ASSUME_CIRCULAR_LAYOUT_FOR_CONNECTION_LENGTH:
            d[d > x // 2] = x - d[d > x // 2]
            assert np.all(d >= 0)
            assert np.all(d <= x // 2)
        print(f"{i:3}", ascii_histogram(g)[0], "   ", ascii_histogram_compressed(d)[0], "xx", ascii_histogram_compressed(d, bins=6)[0])
        total_wire += np.sum(d)
    print("   ","0&⇒A⇐B⊕||⊕B⇐A⇒&1")
    print(f"Total wire: {total_wire}, avg: {total_wire//total_gates}")
    print(f"Total gates: {total_gates}")
    input_count = np.max([np.max(conn_a[0,:]), np.max(conn_b[0,:])]) + 1
    return generate_verilog(input_count, gates, conn_a, conn_b)

###########################################################################################

if __name__ == "__main__":
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} <input_npz_file_name> <output_verilog_file_name> (optional: <max_layers>)")
        sys.exit(1)

    npz_file_name = sys.argv[1]
    if len(sys.argv) == 3:
        verilog_file_name = sys.argv[2]
    else:
        verilog_file_name = os.path.splitext(npz_file_name)[0] + ".v"
    max_layers = -1
    if len(sys.argv) > 3:
        max_layers = int(sys.argv[3])

    data = load_npz_file(npz_file_name)
    verilog = f"// Generated from: {npz_file_name}\n" + \
        f"// {additional_meta_info()}\n" + \
        npz_to_verilog(data, max_layers)

    save_verilog_file(verilog_file_name, verilog)
    print(f"Verilog code has been generated and saved to '{verilog_file_name}'.")

