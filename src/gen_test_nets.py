import numpy as np

GATE_TYPES = 16
GATE_OR  = 0b0111
GATE_AND = 0b0001
GATE_XOR = 0b0110

def net(layer_count, gates_per_layer, connection_dispersions = (0,0), connection_rolls = (0,1), input_count=-1, limit_by="reflection"):
    np.random.seed(1337)
    
    def connect(input_count, output_count, dispersion, roll):
        assert dispersion < output_count
        assert abs(roll) < output_count
        noise = np.random.randint(low=-dispersion, high=dispersion+1, size=output_count)
        connections = np.linspace(0, input_count-1, num=output_count, dtype=np.int32) # distribute connections evenly
        connections = np.roll(connections, roll)
        connections = connections + noise

        def limit_by_clamp(arr, N, R=0):
            zero_to_N = np.linspace(0, N-1, num=len(arr), dtype=np.int32)

            # limit by max
            arr %= N

            # handle negative values
            mask = arr < 0
            arr[mask] = N + arr[mask]

            # limit long connections
            diff = arr - zero_to_N
            mask = diff >= (N - R)
            arr[mask] = 0
            mask = -diff >= (N - R)
            arr[mask] = N - 1

            assert np.all(arr >= 0)
            assert np.all(arr <  N)
            assert np.all(np.abs(arr - zero_to_N) <= R)
            return arr

        def limit_by_reflection(arr, N, R=0):
            zero_to_N = np.linspace(0, N-1, num=len(arr), dtype=np.int32)

            # limit by max
            arr %= N

            # handle negative values
            mask = arr < 0
            arr[mask] = N + arr[mask]

            # limit long connections
            diff = arr - zero_to_N
            mask = diff >= (N - R)
            arr[mask] = (N - 1) - arr[mask] + 1 # reflect around left (0)
            mask = -diff >= (N - R)
            arr[mask] = (N - 1) - arr[mask] - 1 # reflect around right (N)

            assert np.all(arr >= 0)
            assert np.all(arr <  N)
            assert np.all(np.abs(arr - zero_to_N) <= R)
            return arr

        return limit_by_reflection(connections, N=input_count, R=abs(roll) + abs(dispersion)) if limit_by.startswith("refl") else \
               limit_by_clamp     (connections, N=input_count, R=abs(roll) + abs(dispersion))

    inputs = [gates_per_layer] * layer_count
    if input_count > 0:
        inputs[0] = input_count

    gates = np.random.randint(low=1, high=GATE_TYPES-1, size=(layer_count, gates_per_layer)) # exclude constant 0 (0b0000) and contant 1 (0b1111)
    connections_a = [connect(inputs[layer], gates_per_layer, connection_dispersions[0], connection_rolls[0]) for layer in range(layer_count)]
    connections_b = [connect(inputs[layer], gates_per_layer, connection_dispersions[1], connection_rolls[1]) for layer in range(layer_count)]

    return gates, [np.vstack(connections_a),
                   np.vstack(connections_b)]

def save(npz_file_name, gates, connections):
    numpy_dict = {  "gate_types" : gates,
                    "connections.A" : connections[0],
                    "connections.B" : connections[1] }
    np.savez(npz_file_name, **numpy_dict)

# model = net(3, 15, connection_dispersions=(0,0), connection_rolls=(0,1))
# save("test_rnd_d0r1_3x15_15i_15o.npz", *model)
# save("test_xor_d0r1_3x15_15i_15o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,1))
save("test_rnd_d0r1_8x256_256i_256o.npz", *model)
save("test_xor_d0r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])
save("test_or_d0r1_8x256_256i_256o.npz",  np.full_like(model[0], GATE_OR ), model[1])
#save("test_and_d0r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_AND), model[1])

# model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,2))
# save("test_rnd_d0r2_8x256_256i_256o.npz", *model)
# save("test_xor_d0r2_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,4))
save("test_rnd_d0r4_8x256_256i_256o.npz", *model)
#save("test_xor_d0r4_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(1,1), connection_rolls=(0,1))
save("test_rnd_d1r1_8x256_256i_256o.npz", *model)
#save("test_xor_d1r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(4,4), connection_rolls=(0,1))
save("test_rnd_d4r1_8x256_256i_256o.npz", *model)
save("test_xor_clamped4r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(8,8), connection_rolls=(0,1), limit_by="clamp")
save("test_xor_clamped8r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(16,16), connection_rolls=(0,1))
save("test_rnd_d16r1_8x256_256i_256o.npz", *model)
save("test_xor_d16r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])
save("test_or_d16r1_8x256_256i_256o.npz",  np.full_like(model[0], GATE_OR ), model[1])
save("test_and_d16r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_AND), model[1])

model = net(8, 256, connection_dispersions=(16,16), connection_rolls=(0,1), limit_by="clamp")
save("test_xor_clamped16r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(32,32), connection_rolls=(0,1))
save("test_rnd_d32r1_8x256_256i_256o.npz", *model)
save("test_xor_d32r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

# model = net(8, 1024, connection_dispersions=(0,0), connection_rolls=(0,1), input_count=256)
# save("test_rnd_d00r01_8x1024_256i_1024o.npz", *model)
# save("test_xor_d00r01_8x1024_256i_1024o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 1024, connection_dispersions=(0,4), connection_rolls=(0,1), input_count=256)
save("test_rnd_d04r1_8x1024_256i_1024o.npz", *model)
save("test_xor_d04r1_8x1024_256i_1024o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 1024, connection_dispersions=(16,16), connection_rolls=(0,1), input_count=256)
save("test_rnd_d16r1_8x1024_256i_1024o.npz", *model)
save("test_xor_d16r1_8x1024_256i_1024o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 2048, connection_dispersions=(16,16), connection_rolls=(0,1), input_count=256)
save("test_rnd_d16r1_8x2048_256i_1024o.npz", *model)

model = net(4, 4096, connection_dispersions=(16,16), connection_rolls=(0,1), input_count=256)
save("test_rnd_d16r1_4x4096_256i_1024o.npz", *model)
