//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/09/2021 Tue 20:03 
// Filename: 		mcdf_env.sv
// class Name: 		mcdf_env
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Top Environment contains all of the agents, scoreboard, refmod.
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_ENV_SV
`define MCDF_ENV_SV

class mcdf_env extends uvm_driver #(reg_trans);

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	chnl_agt	chnl_agt_i	;
	reg_agt		reg_agt_i	;
	fmt_agt		fmt_agt_i	;
	mcdf_scb	scb_i		;
	mcdf_cov	cov_i		;
	mcdf_vsqr	vsqr_i		;
	
	//delcare mcdf_rgm_handle, adapter handle and predictor handle.
	mcdf_rgm						rgm_i;
	reg2mcdf_adapter				adapter_i;
	uvm_reg_predictor #(reg_trans)	predictor;
	//Factory Registration
	//
    `uvm_component_utils(mcdf_env)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_env", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	
endclass

//Constructor
function void mcdf_env::new(string name = "mcdf_env", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void mcdf_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	foreach(chnl_agt_i[i])chnl_agt_i = chnl_agt::type_id::create("chnl_agt_i", this);
	reg_agt_i	= reg_agt::type_id::create("reg_agt_i", this);		
	fmt_agt_i	= fmt_agt::type_id::create("fmt_agt_i", this);	
	scb_i		= mcdf_scb::type_id::create("scb_i", this);
	cov_i		= mcdf_cov::type_id::create("cov_i", this);
	vsqr_i		= mcdf_vsqr::type_id::create("vsqr_i", this);
	//register model
	rgm_i		= mcdf_rgm::type_id::create("rgm_i", this);
	rgm_i.build();
	adapter_i	= reg2mcdf_adapter::type_id::create("adapter_i". this)
	predictor	= uvm_reg_predictor#(reg_trans)::type_id::create("predictor", this);
endfunction

//connect phase
function void mcdf_env::mcdf_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	chnl_agt_i[0].mon_i.mon_bp_port.connect(scb_i.chnl0_bp_imp);
	chnl_agt_i[1].mon_i.mon_bp_port.connect(scb_i.chnl1_bp_imp);
	chnl_agt_i[2].mon_i.mon_bp_port.connect(scb_i.chnl2_bp_imp);
	fmt_agt_i.mon_i.mon_bp_port.connect(scb_i.fmt_bp_imp);
	reg_agt_i.mon_i.mon_bp_port.connect(scb_i.reg_bp_imp);
	//connect virtual sequencer with agents sequencer
	vsqr_i.reg_sqr	= reg_agt_i.sqr_i;
	vsqr_i.fmt_sqr	= fmt_agt_i.sqr_i;
	vsqr_i.mcdf_rgm	= rgm_i;
	foreach(vsqr_i.chnl_sqr[i])
		vsqr_i.chnl_sqr[i] = chnl_agt_i.sqr_i;
	//register model, set map, adapter
	rgm_i.map.set_sequencer(reg_agt.sqr_i, adapter_i);
	reg_agt.mon_i.mon_ana_port.connect(predictor.bus_in);
	predictor.map 		= rgm_i.map;
	predictor.adapter 	= adapter_i;	
	
endtask



`endif