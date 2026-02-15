![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)


# World smallest written digit classificastion ASIC using Logic Gate Networks

ASIC implementation for [LILogic Net: Compact Logic Gate Networks with Learnable Connectivity for Efficient Hardware Deployment](https://arxiv.org/abs/2511.12340) paper.
- `10K` logic gates, `0.8mm x 0.4mm` die area
- `97.60%` test accuracy
- `100 ns` inference latency

Tapeouts:
- SKY130 [SkyWater Technology Foundry's 130nm node](https://github.com/google/skywater-pdk)
- SG13 [IHP Foundry's BiCMOS 130nm node](https://github.com/IHP-GmbH/IHP-Open-PDK)
- GF180 [Global Foundry's 180nm node](https://github.com/google/gf180mcu-pdk)
- **Coming soon** TSMC65 65nm node


## Setup

```
pip3 install -r requirements.txt
```

## Regenerate Verilog from Logic Gate Network trained in PyTorch

```
python3 src/pth_to_verilog.py src/20250915-070516_binTestAcc9760_seed230646_epochs100_2x4000_b256_lr30_interconnect.pth src/net.v
```

Expected output in the console:
```
Number of layers:  2
Number of new null gates & connections added for padding: 4350
Total number of gates in the network: 8000

Layer statistics:
      _ _   ___ _ _ 
    0&⇒A⇐B⊕||⊕B⇐A⇒&1     0...4..........16..............32.... connection distance .....>64
  0   ▁▁▁▁▂▂▂▂▁▁▁▁▁      ▁▁▁▁         ▁▁▁▁▁▁▁         ▁▁▁▁▁▁▁        ▁▁▁▁▁▁             ▄ xx ▂▂▂▁▁▁▁▁
  1 ▄▁▁▁▁▁▂▁▁▂▁▁▁▁▁      ▄                                                              ▆ xx ▄▁▁▁▁▁▁▁
    0&⇒A⇐B⊕||⊕B⇐A⇒&1
Total wire: 2800632, avg: 350
Total gates: 8000
Verilog code has been generated and saved to 'src/net.v'.
```

## Test locally

```
cd test
make
```

Tests run for a couple of minutes, expected output in the console:

```
0000000000000000 best index: 2 value: 66
0000000000000000 best index: 0 value: 75
0000111111100000 best index: 0 value: 72
0001111111110000 best index: 2 value: 69
0011100000010000 best index: 5 value: 75
0001000010010000 best index: 2 value: 74
0001110111110000 best index: 5 value: 78
0000111111110000 best index: 5 value: 75
0000001111100000 best index: 2 value: 73
0000000011100000 best index: 3 value: 74
0000000111000000 best index: 3 value: 73
0000001110000000 best index: 9 value: 73
0000011100000000 best index: 3 value: 69
0001111000000000 best index: 9 value: 67
0001110000000000 best index: 9 value: 69
0001000000000000 best index: 6 value: 82
3050000.00ns INFO     cocotb.tb                          Computed best index: 6 value: 87
3050000.00ns INFO     cocotb.tb                          Expected output of the last layer: 011010000011010110001001001000001001000000111100011000101000110001001111110001000010011001000010100000110000000000010100011010000110100000100000110010110110010100111111000001100101000011000001010101001000011011000111001101110100000000000010000100111100011111000000111001100111011011000010000100000001010101001110001000110011111111010000000101101100111000010100000101010010111000000100111100001001101011100000000000000100111001111001000100011110010100101010011001100000010101010100110000101111011001000000000000011101101001001000000000100011100111001001101101100000100100011000100110100111111000011000101000101000111100000011001110010010011100111000001110110011111000000010110100111100111010100111011010001100110010111011000111111101110010101100000010010111011111011001000100010111010000010111100010111110000001010000100111110110011101010100101101100100010110011011101001101111100000011000011011010000001100010001110011101110010101111101000010111010000110000001110010000101110111100111001000010001101101100110001100100111000001110101001100001001001101110100101100111010001000000010110011001000110110101000011100100000100000010000000110010011100000000110100000110010100010000111010100101101011011011110101001101001000100110001000111010111100000011010111000001010010010100110011110111000100001111010110000110100110101011100010111110110111010001000011001010110100100100110001010111101100111101010110100011001101011011110011011110011111111111110001110001100011011111101101110010110111010011101100000101011001001000101100101100101000111101111111101101000111101111101111001111000000011101001101111101101111110010110110010110101111101100100111011011110111111111101101110101111011111111101101101011110111111110011110110110111100110111011100100011101111111001010011110110010111101011100111000111000000101101001000010000111110111000001011010000010000010101110011010100011110000110001010000010000000000001010110010000000000100101110110100100100101000001000010000010010000100000111010000000001000010001001000100001101000101001000110000000010101001000100101110011110100111001011011000101101010010111110011010011000010101011010110110110001111000111010001011010010011010000000000100110110100000111011101111111101001000101110101001110000010101101010001111011010100001011001010100110010101011011100011110110001100001100010001000110010100110010110010000001000110110100001000001010000101101000000000000011110101011100010010100001010111010101101101000100110001000111001101010000000001000010000100011000100011100101101001001010001010001100011011000000101000110111010110001
[ 95. 103. 124. 121. 105. 141. 174.  81. 130.  97.]
3050000.00ns INFO     cocotb.tb                          Expected category: 6
3050000.00ns INFO     cocotb.tb                          Computed category: 6
3050000.00ns INFO     cocotb.tb                          Expected value: 87
3050000.00ns INFO     cocotb.tb                          Computed value: 87
3050000.00ns INFO     cocotb.regression                  test_project passed
3050000.00ns INFO     cocotb.regression                  **************************************************************************************
                                                         ** TEST                          STATUS  SIM TIME (ns)  REAL TIME (s)  RATIO (ns/s) **
                                                         **************************************************************************************
                                                         ** test.test_project              PASS     3050000.00          55.17      55282.24  **
                                                         **************************************************************************************
                                                         ** TESTS=1 PASS=1 FAIL=0 SKIP=0            3050000.00          55.62      54832.03  **
```

## Harden locally

NOTE: Tiny Tapeout's [GitHub Actions](actions) will *automatically* harden the design and prepare GDS every time the new changes are committed to the repository.

To harden locally read about the setup:
https://www.tinytapeout.com/guides/local-hardening/


### What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.
To learn more and get started, visit https://tinytapeout.com.
- [FAQ](https://tinytapeout.com/faq/)
- [Join the community](https://tinytapeout.com/discord)
