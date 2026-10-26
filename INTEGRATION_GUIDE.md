# Ara-Core: Hardware Integration & Pinout Guide
**2.0 GHz 6-Stage True-FMA & 16x16 Systolic Matrix Engine**

---

## 1. Top-Level Module Instantiation

Ara-Core provides two tightly-coupled execution macros:
1. `ara_multicore_true_fma_6stage`: 16-Lane IEEE-754 vector arithmetic pipeline.
2. `ara_systolic_tensor_unit`: 16x16 2D systolic matrix multiply-accumulate array.

### SystemVerilog Instantiation: 6-Stage True-FMA Pipeline

```systemverilog
ara_multicore_true_fma_6stage #(
    .NUM_LANES     (16),   // 16 parallel vector execution lanes
    .DATA_WIDTH    (32),   // 32-bit internal FP32 representation
    .SKID_DEPTH    (2)     // 2-entry downstream backpressure skid buffer
) u_true_fma (
    .clk           (clk_core_2000mhz),    // Primary compute clock (2.0 GHz)
    .rst_n         (sys_rst_n),           // Active-low synchronous reset

    // Vector Operand Inputs (Ready/Valid Handshake)
    .valid_i       (vpu_fma_valid),       // Ingress instruction valid
    .ready_o       (vpu_fma_ready),       // Core ready to accept operands
    .data_fmt_i    (vpu_data_fmt[1:0]),   // 00: FP16, 01: BF16, 10: FP8, 11: INT
    .op_mode_i     (vpu_op_mode[2:0]),    // FMA (A*B+C), ADD, SUB, MUL, DOT_PROD
    .act_mode_i    (vpu_act_mode[1:0]),   // 00: None, 01: ReLU, 10: PWL SiLU
    .op_a_i        (vpu_operand_a[511:0]),// 16 lanes x 32-bit packed operands
    .op_b_i        (vpu_operand_b[511:0]),// 16 lanes x 32-bit packed operands
    .op_c_i        (vpu_operand_c[511:0]),// 16 lanes x 32-bit packed addends

    // Result Outputs & Telemetry
    .res_valid_o   (fma_res_valid),       // Result data valid
    .res_ready_i   (fma_res_ready),       // Downstream receiver ready (backpressure)
    .res_data_o    (fma_res_data[511:0]), // 16 lanes x 32-bit normalized output
    .scalar_dot_o  (fma_dot_product[31:0]),// 16-to-1 binary adder reduction output
    .status_flags_o(fma_status_flags[3:0]) // IEEE-754 NV, DZ, OF, UF flags
);
```

### SystemVerilog Instantiation: 16x16 Systolic Matrix Engine

```systemverilog
ara_systolic_tensor_unit #(
    .ARRAY_DIM     (16)    // 16 rows x 16 columns (256 PEs)
) u_systolic_matrix (
    .clk           (clk_core_2000mhz),
    .rst_n         (sys_rst_n),

    // Matrix Execution Control
    .tile_valid_i  (matrix_start_valid),  // Initiate matrix contraction
    .tile_ready_o  (matrix_unit_ready),   // Engine ready for new tile
    .tile_op_i     (matrix_tile_op[1:0]), // 00: Reset, 01: GEMM, 10: Outer-Product
    .k_len_i       (matrix_k_len[15:0]),  // Contraction dimension length K
    .act_clamp_i   (matrix_act_clamp[1:0]),// Activation clamp (01: Fused ReLU)

    // Streaming Data Feeds
    .row_act_i     (row_activations[255:0]), // 16 rows x 16-bit FP16 activations
    .col_wt_i      (col_weights[255:0]),     // 16 cols x 16-bit FP16 weights

    // Matrix Output Drain
    .tile_done_o   (matrix_done_strobe),  // Asserted when K contraction complete
    .drain_valid_o (drain_data_valid),    // Pulsed during result readout
    .drain_row_o   (drain_row_idx[3:0]),  // Row index being drained (0..15)
    .drain_data_o  (drain_row_data[511:0])// 16 columns x 32-bit FP32 words
);
```

---

## 2. Pinout & Signal Dictionary

| Signal Name | Direction | Type / Clock | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | Digital (2.0 GHz) | Core operating clock ($500\text{ ps}$ period). |
| `rst_n` | Input | Sync Active-Low | Synchronous reset. Minimum assertion: 2 clock cycles. |
| `valid_i` / `ready_o` | In/Out | Handshake | Two-way flow control preventing pipeline buffer overflow. |
| `data_fmt_i[1:0]` | Input | Control | Data format (`00`=FP16, `01`=BF16, `10`=FP8, `11`=INT8/32). |
| `act_mode_i[1:0]` | Input | Control | Fused activation (`00`=None, `01`=ReLU, `10`=PWL SiLU). |
| `op_a_i`, `op_b_i`, `op_c_i` | Input | 512-bit Vector | 16 parallel lanes of vector operands. |
| `res_data_o` | Output | 512-bit Vector | 16 parallel lanes of IEEE-754 normalized results. |
| `scalar_dot_o` | Output | 32-bit Scalar | 16-to-1 binary adder reduction tree dot-product. |
| `status_flags_o[3:0]` | Output | Flags | Bit 3: Invalid (NV), Bit 2: DivByZero, Bit 1: Overflow, Bit 0: Underflow. |
| `tile_op_i[1:0]` | Input | Control | Systolic tile command (`01`=Rank-1 GEMM accumulation). |
| `drain_data_o` | Output | 512-bit Vector | Drained systolic row (16 columns $\times$ 32-bit FP32). |

---

## 3. Voltage Regulator Specifications & Power Supply Network

The Ara-Core computes at a high switching activity factor ($\alpha \approx 0.45$) during dense matrix multiplication. Tight regulation of the digital core rail is mandatory.

| Supply Rail | Nominal Voltage | Tolerance | Maximum Ripple | Transient Load Step | Function |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`VDD_CORE`** | **0.75 V** | **$\pm 3.0\%$ ($\pm 22.5\text{ mV}$)** | **$< 15\text{ mV}$** | **$< 10\text{ ns}$ (0.2A to 2.4A)** | FMA datapath, multiplier arrays, PEs. |
| **`VDD_RET`** | **0.65 V** | **$\pm 5.0\%$ ($\pm 32.5\text{ mV}$)** | **$< 20\text{ mV}$** | **$< 50\text{ ns}$** | SRAM retention & clock-gated sleep state. |
| **`VDD_IVR`** | **1.80 V** | **$\pm 5.0\%$ ($\pm 90.0\text{ mV}$)** | **$< 35\text{ mV}$** | **$< 25\text{ ns}$** | Input to on-die integrated GaN regulators. |

### Decoupling & Inrush Current Suppression
1. **Per-Lane Decoupling**: Integrate $15\text{ pF}$ deep trench MOS capacitors adjacent to each of the 16 arithmetic lanes ($240\text{ pF}$ total per core) to absorb local high-frequency switching noise.
2. **Dynamic Clock Gating**: The core automatically gates clock distribution to idle lanes when the vector length $VLEN < 16$, reducing dynamic switching power by up to $78\%$.
3. **Power Staggering**: When transitioning from sleep to active systolic execution, power is stepped over an 8-cycle ramp to eliminate di/dt inductive supply bounce.

---

## 4. On-Die Temperature & Voltage Droop Sensors

Each Ara-Core incorporates dedicated analog sensing blocks connected directly to the tile telemetry network:
1. **Digital Thermal Sensor (DTS)**:
   - Proportional-to-Absolute-Temperature (PTAT) diode sensor with 10-bit SAR ADC.
   - Sample Rate: $1\text{ MSPS}$ continuous.
   - Automated Thermal Gating:
     * $T_j \ge 95^\circ\text{C}$: Flags high-temperature telemetry register.
     * $T_j \ge 110^\circ\text{C}$: Hardware automatically injects 1 wait-state cycle every 4 cycles ($25\%$ throttling).
     * $T_j \ge 125^\circ\text{C}$: Emergency hardware shutdown; core clocks are gated within 1 cycle.
2. **Fast Dynamic Voltage Sensor (DVS)**:
   - 31-stage high-speed ring oscillator measuring local IR drop.
   - If $V_{DD\_CORE}$ sags below $675\text{ mV}$ ($-10\%$ droop), the core asserts `clock_stretch_req`, dynamically extending the clock period by $200\text{ ps}$ to prevent setup time timing violations.
