include paths.mak

# RTL- Source dir of m-labs version of lm32
# HDMI- Root of HDMI2USB-litex-firmware

OUTDIR = $(HDMI)/build/mimasv2_iverilog_lm32

SOURCES = lm32_config.v
SOURCES += $(RTL)/lm32_adder.v $(RTL)/lm32_addsub.v $(RTL)/lm32_cpu.v
SOURCES += $(RTL)/lm32_dcache.v $(RTL)/lm32_debug.v $(RTL)/lm32_decoder.v
SOURCES += $(RTL)/lm32_dp_ram.v $(RTL)/lm32_icache.v
SOURCES += $(RTL)/lm32_instruction_unit.v $(RTL)/lm32_interrupt.v
SOURCES += $(RTL)/lm32_jtag.v $(RTL)/lm32_load_store_unit.v
SOURCES += $(RTL)/lm32_logic_op.v $(RTL)/lm32_mc_arithmetic.v
SOURCES += $(RTL)/lm32_multiplier.v $(RTL)/lm32_ram.v $(RTL)/lm32_shifter.v
SOURCES += $(RTL)/lm32_itlb.v $(RTL)/lm32_dtlb.v
SOURCES += $(RTL)/lm32_top.v

SOURCES += $(OUTDIR)/gateware/top.v

all: sim

$(HDMI)/targets/mimasv2/iverilog.py:
	cp iverilog.py $(HDMI)/targets/mimasv2/iverilog.py

$(OUTDIR)/gateware/top.v: $(HDMI)/targets/mimasv2/iverilog.py $(HDMI)/firmware/*.c
	cd $(HDMI) && PYTHONPATH=$(HDMI) CPU=lm32 PLATFORM=mimasv2 PYTHON=python3 JIMMO=1 TARGET=iverilog make firmware

HDMI_tb.vvp: HDMI_tb.v $(OUTDIR)/gateware/top.v $(OUTDIR)/gateware/mem.init $(OUTDIR)/software/bios/bios.bin
	iverilog -o HDMI_tb.vvp -I. -I$(RTL) HDMI_tb.v $(SOURCES)
	cp $(OUTDIR)/gateware/mem.init .
	lm32-elf-objdump -d $(OUTDIR)/software/bios/bios.elf > bios.asm

sim: HDMI_tb.vvp
	vvp HDMI_tb.vvp
