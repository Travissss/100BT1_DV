
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/11/2020 Thu 19:40
// Filename: 		mcdf_tb.v
// class Name: 		mcdf_tb
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Test bench include interface, DUT. And need to set interface
//////////////////////////////////////////////////////////////////////////////////

`include "param_def.v"

import uvm_pkg::*;
`include "uvm_macros.sv"

import chnl_pkg::*;
import arb_pkg::*;
import fmt_pkg::*;
import reg_pkg::*;
import mcdf_pkg::*;
`include "mcdf_intf.sv"

module mcdf_tb();

logic	clk;
logic	rstn;

mcdf dut(
	.clk_i			(clk				),
	.rstn_i			(rstn				),
	.cmd_i			(reg_if.cmd			),
	.cmd_addr_i		(reg_if.cmd_addr	),
	.cmd_data_i		(reg_if.cmd_data_s2m),
	.cmd_data_o		(reg_if.cmd_data_m2s),

	.ch0_data_i		(chnl0_if.ch_data	),
	.ch0_vld_i		(chnl0_if.ch_valid	),
	.ch1_data_i		(chnl1_if.ch_data	),
	.ch1_vld_i		(chnl1_if.ch_valid	),
	.ch2_data_i		(chnl2_if.ch_data	),
	.ch2_vld_i		(chnl2_if.ch_valid	),
	.ch0_ready_o	(chnl0_if.ch_ready	),
	.ch1_ready_o	(chnl1_if.ch_ready	),
	.ch2_ready_o	(chnl2_if.ch_ready	),
            
	.fmt_grant_i	(fmt_if.fmt_grant	),
	.fmt_chid_o		(fmt_if.fmt_chid	),
	.fmt_req_o		(fmt_if.fmt_req		),
	.fmt_length_o	(fmt_if.fmt_length	),
	.fmt_data_o		(fmt_if.fmt_data	),
	.fmt_start_o	(fmt_if.fmt_start	),
	.fmt_end_o 		(fmt_if.fmt_end 	)
);

reg_intf	reg_if	(.*);
chnl_intf	chnl0_if(.*);
chnl_intf	chnl1_if(.*);
chnl_intf	chnl2_if(.*);
arb_intf	arb_if	(.*);
fmt_intf	fmt_if	(.*);
mcdf_intf	mcdf_if	(.*);

//mcdf interface monitoring MCDF ports and signals
assign mcdf_if.chnl_en[0]	= dut.ctrl_regs_inst.slv0_en_o;
assign mcdf_if.chnl_en[1]	= dut.ctrl_regs_inst.slv1_en_o;
assign mcdf_if.chnl_en[2]	= dut.ctrl_regs_inst.slv2_en_o;

//arbiter interface monitoring arbiter ports
assign arb_if.slv_prios[0]	= dut.arbiter_inst.slv0_prio_i;
assign arb_if.slv_prios[1]	= dut.arbiter_inst.slv1_prio_i;
assign arb_if.slv_prios[2]	= dut.arbiter_inst.slv2_prio_i;
assign arb_if.slv_reqs[0]	= dut.arbiter_inst.slv0_req_i;
assign arb_if.slv_reqs[1]	= dut.arbiter_inst.slv1_req_i;
assign arb_if.slv_reqs[2]	= dut.arbiter_inst.slv2_req_i;

assign arb_if.a2s_acks[0]	= dut.arbiter_inst.a2s0_ack_o;
assign arb_if.a2s_acks[1]	= dut.arbiter_inst.a2s1_ack_o;
assign arb_if.a2s_acks[2]	= dut.arbiter_inst.a2s2_ack_o;

assign arb_if.f2a_if_req	= dut.arbiter_inst.f2a_if_req_i;

initial begin
//interface connect
uvm_config_db#(virtual chnl_intf)::set(null	,"uvm_test_top", "chnl0_vif", chnl0_if);
uvm_config_db#(virtual chnl_intf)::set(null	,"uvm_test_top", "chnl1_vif", chnl1_if);
uvm_config_db#(virtual chnl_intf)::set(null	,"uvm_test_top", "chnl2_vif", chnl2_if);

uvm_config_db#(virtual reg_intf)::set(null	,"uvm_test_top", "reg_vif", reg_if);
uvm_config_db#(virtual arb_intf)::set(null	,"uvm_test_top", "arb_vif", arb_if);
uvm_config_db#(virtual fmt_intf)::set(null	,"uvm_test_top", "fmt_vif", fmt_if);
uvm_config_db#(virtual mcdf_intf)::set(null	,"uvm_test_top", "mcdf_vif", mcdf_if);

run_test();
end

`ifdef  DUMP_FSDB
initial begin
	$fsdbDumpfile("mcdf.fsdb");
	$fsdbDumpvars;
	$fsdbDumpSVA;
end
`endif
endmodule
