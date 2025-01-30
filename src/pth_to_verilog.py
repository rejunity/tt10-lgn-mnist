from pth_to_npz import load_pth_file, pth_to_npz
from npz_to_verilog import npz_to_verilog, save_verilog_file
import sys
import os

if len(sys.argv) != 2 and len(sys.argv) != 3:
    print(f"Usage: python {sys.argv[0]} <input_pth_file_name> <output_verilog_file_name>")
    sys.exit(1)

pth_file_name = sys.argv[1]
if len(sys.argv) == 3:
    verilog_file_name = sys.argv[2]
else:
    # verilog_file_name = os.path.splitext(npz_file_name)[0] + ".v"
    verilog_file_name = "net.v"

pth_data = load_pth_file(pth_file_name)
npz_data = pth_to_npz(pth_data)
verilog = f"// Generated from: {pth_file_name}\n" + \
    npz_to_verilog(npz_data)
save_verilog_file(verilog_file_name, verilog)

print(f"Verilog code has been generated and saved to '{verilog_file_name}'.")
