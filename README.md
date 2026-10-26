# Ara-Core: 2.0 GHz 6-Stage True-FMA & 16x16 Systolic Matrix Engine

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Academic Paper](https://img.shields.io/badge/Research_Paper-Read_PAPER.md-blueviolet.svg)](PAPER.md)
[![Clock](https://img.shields.io/badge/Target_Clock-2.0_GHz-brightgreen.svg)]()
[![Standard](https://img.shields.io/badge/Precision-IEEE--754_FP32%2FFP16%2FBF16-blue.svg)]()
[![Rounding](https://img.shields.io/badge/Rounding-Round_to_Nearest_Even_(RNE)-purple.svg)]()


> 🧭 **Silicon Stack Navigation:** [Architecture Home](https://github.com/ITLABSofficial) &nbsp;•&nbsp; [⬅️ Prev: OpenHBM3_PIM_Subsystem](https://github.com/ITLABSofficial/OpenHBM3_PIM_Subsystem) &nbsp;•&nbsp; **Layer 04: `Ara_Core_TrueFMA_Systolic`** &nbsp;•&nbsp; [Next: Ara_Cluster_TCDM_NoC ➡️](https://github.com/ITLABSofficial/Ara_Cluster_TCDM_NoC)

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

## 🗺️ Silicon Architecture Stack & Next-Page Navigation

This repository represents **Layer 04** of our 8-layer unified silicon supercomputing stack. You can navigate sequentially through the entire hardware hierarchy:

```
[01: PHY Layer] ➔ [02: Memory Controller] ➔ [03: Near-Memory PIM] ➔ [04: Ara Core True-FMA]
       ➔ [05: Cluster NoC] ➔ [06: 16-Core SoC] ➔ [07: 64-Core PCIe Card] ➔ [08: 16K WSE Wafer]
```

| Layer | Hardware Component | GitHub Repository | Key Architectural Specifications | Status |
|:---:|:---|:---|:---|:---:|
| **01** | **Physical Layer (PHY)** | [**`Open_HBM3_PHY`**](https://github.com/ITLABSofficial/Open_HBM3_PHY) | 1.18 TB/s HBM3E PHY, 8:1 SerDes, DFE/CTLE, 4.6 GHz WCK, DFI 5.0 | Active |
| **02** | **Memory Controller** | [**`Open_HBM3_Controller`**](https://github.com/ITLABSofficial/Open_HBM3_Controller) | 16-Pseudo-Channel DFI 5.0 Controller, SECDED ECC, Bank Interleaving | Active |
| **03** | **Near-Memory PIM** | [**`OpenHBM3_PIM_Subsystem`**](https://github.com/ITLABSofficial/OpenHBM3_PIM_Subsystem) | 3.2 TB/s Base-Die PIM Engine, FlashAttention, RMSNorm, True-FMA | Active |
| **04** | **Compute Core** | [**`Ara_Core_TrueFMA_Systolic` (Current)**](https://github.com/ITLABSofficial/Ara_Core_TrueFMA_Systolic) | 16x16 Systolic Array & 6-Stage 2.0 GHz True-FMA (1.024 TFLOPS FP16) | Active |
| **05** | **Cluster Interconnect** | [**`Ara_Cluster_TCDM_NoC`**](https://github.com/ITLABSofficial/Ara_Cluster_TCDM_NoC) | 4-Core Vector Cluster, 32-Bank TCDM SRAM (256 GB/s), 5-Port VC Router | Active |
| **06** | **Multicore SoC** | [**`Ara_16Core_2x2_SoC`**](https://github.com/ITLABSofficial/Ara_16Core_2x2_SoC) | 16-Core GALS NoC Multicore SoC, 4-Zone PDN Stagger, Linux C Driver | Active |
| **07** | **Board / Accelerator** | [**`Ara_PCIe_AI_Accelerator_64Core`**](https://github.com/ITLABSofficial/Ara_PCIe_AI_Accelerator_64Core) | 64-Core PCIe Gen5 x16 AI Card, 128 GB HBM3e Address Space (229W TDP) | Active |
| **08** | **Wafer-Scale Engine** | [**`WSE_16K_Wafer_Scale_Engine`**](https://github.com/ITLABSofficial/WSE_16K_Wafer_Scale_Engine) | 300mm Monolithic 16,384-Core Wafer Engine, 48x HBM3 (1.15 TB), 15 kW | Active |

<div align="center">

| ⬅️ **Previous Component** | 🏠 **Architecture Ecosystem** | ➡️ **Next Component** |
|:---:|:---:|:---:|
| [**⬅️ OpenHBM3_PIM_Subsystem**](https://github.com/ITLABSofficial/OpenHBM3_PIM_Subsystem) | [**ITLABSofficial Profile**](https://github.com/ITLABSofficial) | [**Ara_Cluster_TCDM_NoC ➔**](https://github.com/ITLABSofficial/Ara_Cluster_TCDM_NoC) |

</div>

---

## License

This project is licensed under the **Apache License 2.0** - see the [LICENSE](LICENSE) file for details.
