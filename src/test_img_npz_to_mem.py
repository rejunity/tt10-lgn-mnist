import os
import sys
import numpy as np

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

def save_mem_file(file_name, verilog):
    with open(file_name, "w") as f:
        f.write(verilog)

def split_array(lst, chunk_size=8):
    return [lst[i:i + chunk_size] for i in range(0, len(lst), chunk_size)]

def array_to_bin(arr):
    return ''.join(arr.astype(int).astype(str))

def npz_to_mem(data, max_images=-1, interleave_keys=True, reverse_images=True):
    mem = []
    offsets_per_key = [0]
    for key, X in data.items():
        offsets_per_key.append(len(X) + offsets_per_key[-1])
        for x in X:
            mem.append(x)
    offsets_per_key = offsets_per_key[:-1]
    if max_images < 0:
        max_images = len(mem)
    if interleave_keys:
        mem_interleaved = []
        i = 0
        while len(mem_interleaved) < max_images:
            for offset in offsets_per_key:
                if offset + i < len(mem):
                    mem_interleaved.append(mem[offset + i])
            i = i + 1
        mem = mem_interleaved[:max_images]

    bin_str = ""
    for x in mem:
        if reverse_images:
            x = x[::-1]
        # arr = [array_to_bin(block_of_16) for block_of_16 in split_array(x, 16)]
        arr = [array_to_bin(block_of_8) for block_of_8 in split_array(x, 8)]
        arr = [arr[i]+" "+arr[i+1] for i in range(0, len(arr), 2)]
        bin_str += '\n'.join(arr) + "\n"
    print(f"Converted {len(mem)} images.")

    return bin_str

###########################################################################################

if __name__ == "__main__":
    if len(sys.argv) != 2 and len(sys.argv) != 3 and len(sys.argv) != 4:
        print(f"Usage: python {sys.argv[0]} <input_npz_file_name> <output_mem_file_name> (optional max_numbers)")
        sys.exit(1)

    npz_file_name = sys.argv[1]
    if len(sys.argv) > 2:
        verilog_file_name = sys.argv[2]
    else:
        verilog_file_name = os.path.splitext(npz_file_name)[0] + ".mem"
    max_images = -1
    if len(sys.argv) > 3:
        max_images = int(sys.argv[3])

    data = load_npz_file(npz_file_name)
    mem = f"// Generated from: {npz_file_name}\n" + \
        npz_to_mem(data, max_images) 

    save_mem_file(verilog_file_name, mem)
    print(f"Verilog code has been generated and saved to '{verilog_file_name}'.")

