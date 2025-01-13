import numpy as np

GATE_TYPES = 16
GATE_XOR = 0b0110

def net(layer_count, gates_per_layer, connection_dispersions = (0,0), connection_rolls = (0,1), input_count=-1):
    np.random.seed(1337)
    
    def connect(input_count, output_count, dispersion, roll):
        assert dispersion < output_count
        assert abs(roll) < output_count
        noise = np.random.randint(low=-dispersion, high=dispersion+1, size=output_count)
        connections = np.linspace(0, input_count-1, num=output_count, dtype=np.int32) # distribute connections evenly
        connections = np.roll(connections, roll)
        connections = connections + noise

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

        return limit_by_reflection(connections, N=input_count, R=abs(roll) + abs(dispersion))

    inputs = [gates_per_layer] * layer_count
    if input_count > 0:
        inputs[0] = input_count

    gates = np.random.randint(low=0, high=GATE_TYPES, size=(layer_count, gates_per_layer))
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

# model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,2))
# save("test_rnd_d0r2_8x256_256i_256o.npz", *model)
# save("test_xor_d0r2_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,4))
save("test_rnd_d0r4_8x256_256i_256o.npz", *model)
save("test_xor_d0r4_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(1,1), connection_rolls=(0,1))
save("test_rnd_d1r1_8x256_256i_256o.npz", *model)
save("test_xor_d1r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(4,4), connection_rolls=(0,1))
save("test_rnd_d4r1_8x256_256i_256o.npz", *model)
save("test_xor_d4r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(16,16), connection_rolls=(0,1))
save("test_rnd_d16r1_8x256_256i_256o.npz", *model)
save("test_xor_d16r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

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
