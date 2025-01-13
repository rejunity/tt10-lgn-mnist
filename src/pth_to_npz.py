import torch
import torch.nn.functional as F
import numpy as np
import sys
import os

# Reference for network training: https://gist.github.com/rejunity/bff3857ce1fad9f11fbfed0db0f2bbc8

if len(sys.argv) != 2 and len(sys.argv) != 3:
    print("Usage: python load_npz_file.py <input_npz_file_name> <output_verilog_file_name>")
    sys.exit(1)

pth_file_name = sys.argv[1]
if len(sys.argv) == 3:
	npz_file_name = sys.argv[2]
else:
	npz_file_name = os.path.splitext(pth_file_name)[0] + ".npz"

checkpoint = torch.load(pth_file_name, map_location=torch.device('cpu'), weights_only=True)

if isinstance(checkpoint, dict):
    connections = checkpoint.pop("connections")
    layers = [checkpoint[f"layers.{layer_idx}.w"] for layer_idx in range(len(checkpoint))]

    assert len(connections) == 2
    print("Number of layers: ", len(layers))

    gate_types = [torch.argmax(layer, dim=0) for layer in layers]

    original_size = np.sum([g.size() for g in gate_types] + [c.size() for c in connections[0]] + [c.size() for c in connections[1]])

    def pad_tensor_array(tensors, padding=0):
        max_size = max(t.size(0) for t in tensors)
        padded = [F.pad(t, (0, max_size - t.size(0)), value=padding) for t in tensors]
        return torch.stack(padded, dim=0)

    gate_types = pad_tensor_array(gate_types).cpu().numpy()
    connections[0] = pad_tensor_array(connections[0]).cpu().numpy()
    connections[1] = pad_tensor_array(connections[1]).cpu().numpy()

    padded_size = gate_types.size + connections[0].size + connections[1].size 
    if padded_size > 0:
        print("Number of new null gates & connections added for padding:", padded_size - original_size)

    numpy_dict = {  "gate_types" : gate_types,
                    "connections.A" : connections[0],
                    "connections.B" : connections[1] }
    np.savez(npz_file_name, **numpy_dict)

    print("Totoal number of gates in the network:", np.size(gate_types))
