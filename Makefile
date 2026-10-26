# ==============================================================================
# ARA CORE: 6-STAGE TRUE-FMA & 16x16 SYSTOLIC TENSOR UNIT MAKEFILE
# ==============================================================================

IVERILOG = iverilog -g2012
VVP = vvp
YOSYS = yosys

RTL_FMA = rtl/ara_multicore_true_fma_6stage.sv
RTL_SYSTOLIC = rtl/ara_systolic_tensor_unit.sv
TB_FMA = tb/tb_ara_multicore_fma_6stage.sv
TB_SYSTOLIC = tb/tb_ara_systolic_tensor_unit.sv

.PHONY: all sim_fma sim_systolic test synth clean

all: sim_fma sim_systolic

sim_fma: $(RTL_FMA) $(TB_FMA)
	$(IVERILOG) -o sim_fma $(RTL_FMA) $(TB_FMA)

sim_systolic: $(RTL_FMA) $(RTL_SYSTOLIC) $(TB_SYSTOLIC)
	$(IVERILOG) -o sim_systolic $(RTL_FMA) $(RTL_SYSTOLIC) $(TB_SYSTOLIC)

test: all
	@echo "=== [1/2] RUNNING TRUE-FMA TESTBENCH ==="
	$(VVP) sim_fma
	@echo "=== [2/2] RUNNING SYSTOLIC TENSOR UNIT TESTBENCH ==="
	$(VVP) sim_systolic

test_fma: sim_fma
	$(VVP) sim_fma

test_systolic: sim_systolic
	$(VVP) sim_systolic

synth_check: synth

synth:
	$(YOSYS) -p "read_verilog -sv $(RTL_FMA) $(RTL_SYSTOLIC); hierarchy -check -top ara_systolic_tensor_unit; proc; opt; check -assert"

clean:
	rm -f sim_fma sim_systolic *.vcd
