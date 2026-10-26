# Ara-Core: 2.0 GHz 6-Stage True-FMA & 16x16 Systolic Matrix Engine

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Clock](https://img.shields.io/badge/Target_Clock-2.0_GHz-brightgreen.svg)]()
[![Standard](https://img.shields.io/badge/Precision-IEEE--754_FP32%2FFP16%2FBF16-blue.svg)]()
[![Rounding](https://img.shields.io/badge/Rounding-Round_to_Nearest_Even_(RNE)-purple.svg)]()

**Ara-Core** is a high-performance, synthesizable vector computing IP core combining a fully pipelined **6-stage 2.0 GHz True-Fused Multiply-Add (True-FMA)** unit with a **16x16 Systolic Matrix Tensor Engine**.

---

## Key Features

1. **6-Stage 2.0 GHz True-FMA Pipeline (`ara_multicore_true_fma_6stage.sv`)**:
   - Single-cycle throughput for $A 	imes B \pm C$.
   - **48-bit Internal Mantissa Datapath**: Prevents precision loss and Catastrophic Cancellation.
   - **Leading-Zero Anticipator (LZA)**: Parallel normalizer for denormal and subnormal numbers.
   - **Bit-Exact IEEE-754 Compliance**: Round-to-Nearest-Even (RNE), quiet NaN propagation, and signed zero preservation.
2. **16x16 Systolic Tensor Matrix Engine (`ara_systolic_tensor_unit.sv`)**:
   - 2D systolic array executing dense GEMM and outer-product tensor contractions.
   - Delivers **0.64 TFLOPS FP16 peak** per core at 2.0 GHz.
   - Direct streaming weight buffering with 0-cycle stall during matrix multiply.

---

## Directory Structure

```
.
├── rtl/                          # Synthesizable SystemVerilog RTL
│   ├── ara_multicore_true_fma_6stage.sv # 6-stage 2.0 GHz True-FMA engine
│   └── ara_systolic_tensor_unit.sv      # 16x16 systolic array matrix engine
├── tb/                           # Functional verification environments
│   ├── tb_ara_multicore_fma_6stage.sv   # IEEE-754 corner-case testbench
│   └── tb_systolic_matrix_unit.sv       # Matrix multiplication testbench
├── docs/                         # Architecture documentation
│   └── ARCHITECTURE.md           # Pipeline stage timing breakdown
├── Makefile                      # Automated simulation & synthesis recipes
├── LICENSE                       # Apache-2.0 License
└── README.md                     # Project documentation
```

---

## Verification & Quickstart

```bash
# 1. Run IEEE-754 Corner Case & Golden Model Test
make test_fma

# 2. Run 16x16 Systolic Matrix Multiplication Test
make test_systolic

# 3. Check Synthesizability in Yosys
make synth_check
```

---

## License
Licensed under Apache 2.0.
