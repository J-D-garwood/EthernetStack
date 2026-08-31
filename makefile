TB     = MDC_tb
TB_DIR = testbenches
SRC    = $(wildcard src/MDC.v)
OUT    = sim.out

all: run

$(OUT): $(TB_DIR)/$(TB).v $(SRC)
	iverilog -g2005 -Wall -o $(OUT) $(TB_DIR)/$(TB).v $(SRC)

run: $(OUT)
	vvp $(OUT) -fst

wave:
	gtkwave dump.fst

clean:
	rm -f $(OUT) *.vcd *.fst

# ---- Questa ----
qlib:
	-vlib work

qbuild: qlib
	vlog $(TB_DIR)/$(TB).v $(SRC)

qrun: qbuild
	vsim -c $(TB) -do "run -all; quit"

qwave: qbuild
	vsim -voptargs=+acc $(TB) -do "add wave -r /*; run -all"

qclean:
	-rmdir /S /Q work
	-del /Q transcript vsim.wlf modelsim.ini