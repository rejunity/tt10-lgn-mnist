import numpy as np

GATE_TYPES = 16
GATE_XOR = 0b0110

np.random.seed(1337)

def net(layer_count, gates_per_layer, connection_dispersions = (0,0), connection_rolls = (0,1)):
    def connect(input_count, output_count, dispersion, roll):
        assert dispersion < output_count
        assert abs(roll) < output_count
        noise = np.random.randint(low=-dispersion, high=dispersion+1, size=output_count)
        connections = np.roll(np.arange(output_count), roll)
        connections = connections + noise

        def limit_by_reflection(arr, R=0):
            N = len(arr)

            # limit by max
            arr %= N

            # handle negative values
            mask = arr < 0
            arr[mask] = N + arr[mask]

            # limit long connections
            diff = arr - np.arange(N)
            mask = diff >= (N - R)
            arr[mask] = (N - 1) - arr[mask] + 1 # reflect around left (0)
            mask = -diff >= (N - R)
            arr[mask] = (N - 1) - arr[mask] - 1 # reflect around right (N)

            assert np.all(arr >= 0)
            assert np.all(arr <  N)
            assert np.all(np.abs(arr - np.arange(N)) <= R)
            return arr

        return limit_by_reflection(connections, abs(roll) + abs(dispersion))

    gates = np.random.randint(low=0, high=GATE_TYPES, size=(layer_count, gates_per_layer))
    connections_a = [connect(gates_per_layer, gates_per_layer, connection_dispersions[0], connection_rolls[0]) for layer in range(layer_count)]
    connections_b = [connect(gates_per_layer, gates_per_layer, connection_dispersions[1], connection_rolls[1]) for layer in range(layer_count)]

    return gates, [np.vstack(connections_a),
                   np.vstack(connections_b)]

def save(npz_file_name, gates, connections):
    numpy_dict = {  "gate_types" : gates,
                    "connections.A" : connections[0],
                    "connections.B" : connections[1] }
    np.savez(npz_file_name, **numpy_dict)

model = net(3, 15, connection_dispersions=(0,0), connection_rolls=(0,1))
save("test_rnd_d0r1_3x15_15i_15o.npz", *model)
save("test_xor_d0r1_3x15_15i_15o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,1))
save("test_rnd_d0r1_8x256_256i_256o.npz", *model)
save("test_xor_d0r1_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,2))
save("test_rnd_d0r2_8x256_256i_256o.npz", *model)
save("test_xor_d0r2_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

model = net(8, 256, connection_dispersions=(0,0), connection_rolls=(0,3))
save("test_rnd_d0r3_8x256_256i_256o.npz", *model)
save("test_xor_d0r3_8x256_256i_256o.npz", np.full_like(model[0], GATE_XOR), model[1])

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
