SBT          := sbt
CHISEL_FLAGS :=

executables := emulator/$(filter-out source,\
            $(notdir $(basename $(wildcard source/*.scala))))

tut_outs    := emulator/$(addsuffix .out, $(executables))

all: emulator verilog

check: test-solutions.xml

clean:
	-rm -f emulator/*.h emulator/*.cpp emulator/*.o emulator/*.out verilog/*.v $(executables)
	-rm -rf project/target/ target/

emulator: $(tut_outs)

verilog: verilog/$(addsuffix .v, $(executables))

test-solutions.xml: $(tut_outs)
	$(top_srcdir)/sbt/check $(tut_outs) > $@

emulator/%.out: source/%.scala
	$(SBT) "run $(notdir $(basename $<)) --genHarness --compile --test --backend c --targetDir emulator $(CHISEL_FLAGS)" | tee $@

verilog/%.v: %.scala
	$(SBT) "run $(notdir $(basename $<)) --genHarness --backend v --targetDir verilog $(CHISEL_FLAGS)"

.PHONY: all check clean emulator verilog
