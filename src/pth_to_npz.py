import torch
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
	# npz_file_name = pth_file_name.strip(".pth") + ".npz"
	npz_file_name = os.path.splitext(pth_file_name)[0] + ".npz"

checkpoint = torch.load(pth_file_name, map_location=torch.device('cpu'), weights_only=True)

if isinstance(checkpoint, dict):
    connections = checkpoint.pop("connections")
    layers = [checkpoint[f"layers.{layer_idx}.w"] for layer_idx in range(len(checkpoint))]

    assert len(connections) == 2

    print("Number of layers: ", len(layers))

    gate_types = [torch.argmax(layer, dim=0) for layer in layers];
    gate_types = torch.stack(gate_types, dim=0).cpu().numpy()
    numpy_dict = {  "gate_types" : gate_types,
                    "connections.A" : connections[0],
                    "connections.B" : connections[1] }
    np.savez(npz_file_name, **numpy_dict)

    print("Number of gates: ", np.size(gate_types))
