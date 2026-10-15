
SHELL := /bin/bash

-include config.mk

DESIGN_TOP ?=
DESIGN_DIR ?=
NETLIST ?=
NETLIST_DIR ?=
CONSTR_DIR ?= $(DESIGN_DIR)
CONSTR ?=

.PHONY: all cdc_check synthesis tpower clean

cdc_check: save_config cdc_checker.sh
	@echo "Beginning CDC Check"
	@if [[ -n "$(strip $(NETLIST))" ]]; then \
		if [[ -n "$(strip $(DESIGN_TOP))" ]]; then \
			echo "Error: NETLIST and DESIGN_TOP cannot both be provided."; \
			exit 2; \
		fi; \
		if [[ -z "$(strip $(NETLIST_DIR))" ]]; then \
			echo "Error: NETLIST_DIR is required with NETLIST."; \
			exit 2; \
		fi; \
		./cdc_checker.sh --sv \
			-n "$(NETLIST)" \
			-m "$(NETLIST_DIR)" \
			-p "$(CONSTR_DIR)" \
			-c "$(CONSTR)" \
			-o "$${NETLIST%.*}_cdc_report.json"; \
	elif [[ -n "$(strip $(DESIGN_TOP))" ]]; then \
		if [[ -z "$(strip $(DESIGN_DIR))" ]]; then \
			echo "Error: DESIGN_DIR is required with DESIGN_TOP."; \
			exit 2; \
		fi; \
		if [[ -n "$(strip $(NETLIST_DIR))" ]]; then \
			echo "Error: NETLIST_DIR requires NETLIST."; \
			exit 2; \
		fi; \
		./cdc_checker.sh --sv \
			-t "$(DESIGN_TOP)" \
			-d "$(DESIGN_DIR)" \
			-p "$(CONSTR_DIR)" \
			-c "$(CONSTR)" \
			-o "$(DESIGN_TOP)_cdc_report.json"; \
	else \
		echo "Error: Specify either DESIGN_TOP or NETLIST."; \
		exit 2; \
	fi
	

all: synthesis tpower cdc_check

synthesis: yosys_flow.sh
	@echo "Beginning Synthesis"
	@./yosys_flow.sh
	@echo "Synthesis Complete! Output recorded at yosys_log.log"

tpower: async_fifo_sta.tcl timing_check.sh
	@echo "Opening Timing and Power Simulation"
	@sta async_fifo_sta.tcl
	@./timing_check.sh

clean: clean_files.sh
	@if [[ -n "$(strip $(NETLIST))" ]]; then \
		echo "Preparing cleanup"; \
		./clean_files.sh -d $(NETLIST_DIR)/../CDC_REPORTS; \
	elif [[ -n "$(strip $(DESIGN_TOP))" ]]; then \
		"Preparing cleanup"; \
		./clean_files.sh -d $(DESIGN_DIR)/../CDC_REPORTS; \
	else \
		echo "Error: Could not perform cleanup"; \
		exit 2; \
	fi
	@printf '' > config.mk

save_config:
	@printf 'DESIGN_TOP := %s\n' '$(DESIGN_TOP)' > config.mk
	@printf 'DESIGN_DIR := %s\n' '$(DESIGN_DIR)' >> config.mk
	@printf 'CONSTR	:= %s\n' '$(CONSTR)' >> config.mk
	@printf 'CONSTR_DIR := %s\n' '$(CONSTR_DIR)' >> config.mk
	@printf 'NETLIST := %s\n' '$(NETLIST)' >> config.mk
	@printf 'NETLIST_DIR := %s\n' '$(NETLIST_DIR)' >> config.mk
	@printf 'CDC_OUTPUT := %s\n' '$(CDC_OUTPUT)' >> config.mk
