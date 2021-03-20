.PHONY:com sim clean

seed = 20212021
test = mcdf_data_consistence_basic_test

OUTPUT = mcdf

VCS =	vcs -sgq short:3m:1c -sverilog -timescale=1ns/1ns \
	-cm line+cond+fsm+tgl+branch+assert				\
	-debug_acc_all -debug_region+cell+encrypt		\
	+incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv 	\
	-P ${VERDI_HOME}/share/PLI/VCS/LINUX/novas.tab	\
	${VERDI_HOME}/share//PLI/VCS/LINUX/pli.a		\
	-o ${OUTPUT}									\
	-l compile.log									\
	$(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS	\
	+define+DUMP_FSDB								\
	+fstb+glitch=0									\
	-assert enable_diag -assert_dbgopt
	#+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
	SNPS_VCS_OPT+= -debug_access+cbk\
	+UVM_TESTNAME=mcdf_data_consistence_basic_test

#SIM = sgsub ./${OUTPUT} +fsdb+glitch=0 +fsdb+sva_index_info +fsdb+sva_status -sgq short:3m:1c -sgfg -l simulation.log\
	-cm line+cond+fsm+tgl+branch+assert\

SIM = sgsub ./${OUTPUT} -sgq short:2m:1c -sgfg -l simulation.log	

com:
	${VCS} -f tb.f

sim:
	${SIM}  +UVM_TESTNAME=${test} +plusarg_save +ntb_random_seed=${seed}

verdi:
	verdi -sgq long:8m:1c +v2k -sverilog  -f tb.f -ssf -cov -covdir ${OUTPUT}.vdb ./mcdf.fstb &
	
