# Grid size including IOBs at edges
X = 16
Y = 16
# SLICEs per tile
N = 48
# LUT input count
K = 6
# Number of local wires
Wl = N*(K+1) + 8 
# 1/Fc for bel input wire pips
Si = 4
# 1/Fc for Q to local wire pips
Sq = 4
# ~1/Fc local to neighbour local wire pips
Sl = 8