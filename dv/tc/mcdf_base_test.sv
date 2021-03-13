//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/13/2021 Sun 19:31
// Filename: 		mcdf_base_test.sv
// class Name: 		mcdf_base_test
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> test top include mcdf_env,
//////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"
//just try not include chnl_pkg, fmt_pkg, arb_pkg.....
import mcdf_pkg::*;
//import chnl_pkg::*;
//import reg_pkg::*;
//import arb_pkg::*;
//import fmt_pkg::*;
//import mcdf_rgm_pkg::*;
class mcdf_base_test extends uvm_test;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	virtual chnl_intf	chnl0_vif;
	virtual chnl_intf	chnl1_vif;
	virtual chnl_intf	chnl2_vif;
	virtual reg_intf	reg_vif;
	virtual arb_intf	arb_vif;
	virtual fmt_intf	fmt_vif;
	virtual mcdf_intf	mcdf_vif;
	
	//------------------------------------------
	// Sub Components
	//------------------------------------------
	mcdf_env	env_i;
	
	//Factory Registration
	//
	`uvm_component_utils(mcdf_base_test)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_base_test", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void end_of_elaboration_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
	// User Defined Methods:
	extern task set_interface(	virtual chnl_intf 	chnl0_vif	,
								virtual chnl_intf 	chnl1_vif	,
								virtual chnl_intf 	chnl2_vif	,
								virtual reg_intf 	reg_vif		,
								virtual arb_intf 	arb_vif		,
								virtual fmt_intf 	fmt_vif		,
								virtual mcdf_intf 	mcdf_vif	
	);
	extern task run_top_virtual_sequence();
	extern function int num_uvm_errors();
endclass


//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////

//Constructor
function mcdf_base_test::new(string name = "mcdf_base_test", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void mcdf_base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env_i = mcdf_env::type_id::create("env_i", this);
	
	if(!uvm_config_db#(virtual chnl_intf)::get(this, "", "chnl0_vif", chnl0_vif))
		`uvm_fatal("No chnl0_vif", "chnl0_vif is not set!")
		
	if(!uvm_config_db#(virtual chnl_intf)::get(this, "", "chnl1_vif", chnl1_vif))
		`uvm_fatal("No chnl1_vif", "chnl1_vif is not set!")
		
	if(!uvm_config_db#(virtual chnl_intf)::get(this, "", "chnl2_vif", chnl2_vif))
		`uvm_fatal("No chnl2_vif", "chnl2_vif is not set!")
	
	if(!uvm_config_db#(virtual reg_intf)::get(this,"","reg_vif", reg_vif)) begin
		`uvm_fatal("No reg_vif", "reg_vif is not set!")
	end	
	if(!uvm_config_db#(virtual arb_intf)::get(this,"","arb_vif", arb_vif)) begin
		`uvm_fatal("No arb_intf", "arb_intf is not set!")
	end	
	if(!uvm_config_db#(virtual fmt_intf)::get(this,"","fmt_vif", fmt_vif)) begin
		`uvm_fatal("No fmt_vif", "fmt_vif is not set!")
	end	
	if(!uvm_config_db#(virtual mcdf_intf)::get(this,"","mcdf_vif", mcdf_vif)) begin
		`uvm_fatal("No mcdf_vif", "mcdf_vif is not set!")
	end	
	
endfunction

//connect_phase
function void mcdf_base_test::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	set_interface(chnl0_vif, chnl1_vif, chnl2_vif, reg_vif, fmt_vif, arb_vif, mcdf_vif);

endfunction

//end_of_elaboration_phase
function void mcdf_base_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
	uvm_root::get().set_report_verbosity_level_hier(UVM_HIGH);
	uvm_root::get().set_report_max_quit_count(1);
	uvm_root.get().set_timeout(10ms);
endfunction

//run_phase
task mcdf_base_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	run_top_virtual_sequence();
	
	phase.drop_objection(this);
endtask

function void mcdf_base_test::report_phase(uvm_phase phase);
	super.report_phase(phase);
	if(num_uvm_errors == 0)begin
		`uvm_info(get_type_name(), "Simulation Passed!", UVM_NONE)
	end
	else begin
		`uvm_info(get_type_name(), "Simulation Failed!", UVM_NONE)
	end
endfunction

task mcdf_base_test::set_interface(	virtual chnl_intf 	chnl0_vif	,
									virtual chnl_intf 	chnl1_vif	,
									virtual chnl_intf 	chnl2_vif	,
									virtual reg_intf 	reg_vif		,
									virtual arb_intf 	arb_vif		,
									virtual fmt_intf 	fmt_vif		,
									virtual mcdf_intf 	mcdf_vif);
									
	env_i.chnl_agt_i[0].set_interface(chnl0_vif);
	env_i.chnl_agt_i[1].set_interface(chnl1_vif);
	env_i.chnl_agt_i[2].set_interface(chnl2_vif);
	env_i.fmt_agt_i.set_interface(fmt_vif);
	env_i.reg_vif.set_interface(reg_vif);
	env_i.arb_intf.set_interface(arb_intf);
	
	env_i.scb_i.set_interface(mcdf_vif, '{chnl0_vif, chnl1_vif, chnl2_vif}, arb_vif);
	env_i.cov_i.set_interface('{chnl0_vif, chnl1_vif, chnl2_vif}, reg_vif, arb_vif, fmt_vif, mcdf_vif)；
	env_i.vsqr_i.set_interface(mcdf_vif);
endtask

function int mcdf_base_test::num_uvm_errors();
	uvm_report_server server;
	if(server == null)
		server = get_report_server();
	return server.get_severity_count(UVM_ERROR);
endfunction
