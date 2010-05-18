SHELL := bash

MPWD := $(shell pwd)
QUARTUS := $(MPWD)/mjl_stratix/


QUMACRO := unset LS_COLORS; cd $(QUARTUS); export LD_LIBRARY_PATH=/opt/quartus/quartus/linux64; export LM_LICENSE_FILE=26888@quartus; 


all: $(QUARTUS) 
	@echo "	Quartus start Compilation"
	@$(QUMACRO) quartus_sh --flow compile mjl_stratix

err: $(QUARTUS)
	@clear
	@echo " MAP ERRORS: "
	@grep -i 'error:' $(QUARTUS)*map*.rpt
	
warn: $(QUARTUS)
	@clear
	@echo " MAP WARNINGS: "
	@grep -i 'warning:' $(QUARTUS)*map*.rpt

prj: $(QUARTUS)
	@echo "	make projekt"
	@quartus_sh -t $(QUARTUS)../prj/create_project.tcl

.PHONY: clean
clean:
	@rm -rf $(QUARTUS)*

