import torch
import torch.nn.functional as F
import numpy as np
import sys
import os

# Reference for network training: https://gist.github.com/rejunity/bff3857ce1fad9f11fbfed0db0f2bbc8

def load_pth_file(file_name):
    if not file_name.endswith('.pth'):
        raise ValueError(f"The file '{file_name}' is not a .pth file.")

    if not os.path.isfile(file_name):
        raise FileNotFoundError(f"The file '{file_name}' does not exist.")

    try:
        checkpoint = torch.load(file_name, map_location=torch.device('cpu'), weights_only=True)
        return checkpoint
    except Exception as e:
        raise RuntimeError(f"Failed to load the .pth file: {e}")

def save_npz_file(file_name, npz_data):
    np.savez(file_name, **npz_data)

#--- CORE function ------------------------------------------------------------------------

def pth_to_npz(checkpoint):
    print(checkpoint.keys())

    if "connections" in checkpoint:
        connections = checkpoint.pop("connections")
        layers = [checkpoint[f"layers.{i}.w"] for i in range(len([k for k in checkpoint if k.startswith('layers.') and k.endswith('.w')]))]
    else:
        c = {}
        w = {}
        indices = {}
        for key in checkpoint.keys():
            parts = key.split('.')
            if len(parts) != 3 or parts[0] != 'layers':
                continue  # Skip tensors that don't contain layer parameters
            layer_id, type = int(parts[1]), parts[2]
            # print(layer_id)
            
            value = checkpoint[key]
            if type == 'c':
                # print(value.shape, torch.argmax(value, dim=0).shape, torch.argmax(value, dim=1).shape)
                c[layer_id] = torch.argmax(value, dim=0)
            elif type == 'w':
                w[layer_id] = value
            elif type == 'indices':
                indices[layer_id] = value

        # print(len(c), len(w), len(indices))

        layers = [v for key, v in sorted(w.items(), key=lambda item: item[0])]
        connections = {**c, **indices}
        connections = [v for key, v in sorted(connections.items(), key=lambda item: item[0])]
        assert len(layers) == len(connections), f"{len(layers)} {len(connections)}"

        conn_a = []
        conn_b = []
        for c in connections:
            x = c.view(-1, 2)   # [number_of_gates, 2]
            A = x[:,0]          # [number_of_gates]
            B = x[:,1]          # [number_of_gates]
            # A, B = torch.chunk(c, 2, dim=0)
            conn_a.append(A)
            conn_b.append(B)
        connections = [conn_a, conn_b]

    assert len(connections) == 2
    if "net_architecture" in checkpoint:
        print("Architecture: ", checkpoint["net_architecture"])
    print("Number of layers: ", len(layers))

    dataset_input = [torch.tensor((1,1))] # default
    if "dataset_input" in checkpoint:
        dataset_input = checkpoint.pop("dataset_input")

    dataset_output = [torch.tensor((1,1))] # default
    if "dataset_output" in checkpoint:
        dataset_output = checkpoint.pop("dataset_output")


    gate_types = [torch.argmax(layer, dim=0) for layer in layers]

    original_size = np.sum([g.size() for g in gate_types] + [c.size() for c in connections[0]] + [c.size() for c in connections[1]])

    def pad_tensor_array(tensors, new_size, padding=0):
        padded = [F.pad(t, (0, new_size - t.size(0)), value=padding) for t in tensors]
        return torch.stack(padded, dim=0)

    max_size = max(t.size(0) for t in gate_types)
    gate_types = pad_tensor_array(gate_types, max_size).cpu().numpy()
    connections[0] = pad_tensor_array(connections[0], max_size).cpu().numpy()
    connections[1] = pad_tensor_array(connections[1], max_size).cpu().numpy()

    padded_size = gate_types.size + connections[0].size + connections[1].size 
    if padded_size - original_size > 0:
        print("Number of new null gates & connections added for padding:", padded_size - original_size)
    print("Total number of gates in the network:", np.size(gate_types))

    return {    "gate_types"    : gate_types,
                "connections.A" : connections[0],
                "connections.B" : connections[1],
                "input"         : dataset_input,
                "output"        : dataset_output }

###########################################################################################

if __name__ == "__main__":
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} <input_npz_file_name> <output_verilog_file_name>")
        sys.exit(1)

    pth_file_name = sys.argv[1]
    if len(sys.argv) == 3:
        npz_file_name = sys.argv[2]
    else:
        npz_file_name = os.path.splitext(pth_file_name)[0] + ".npz"

    checkpoint = load_pth_file(pth_file_name)
    data = pth_to_npz(checkpoint)
    save_npz_file(npz_file_name, data)

    print(f"Data has been converted and saved to '{npz_file_name}'.")
