//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/24/2021 Wed 20:19
// Filename: 		chnl_agt.sv
// class Name: 		chnl_agt
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel agent contains monitor, sequencer, driver, connect sqr with driver
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CHNL_AGT_SV
`define MCDF_CHNL_AGT_SV

class chnl_agt extends uvm_agent;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual chnl_intf vif;
    
	chnl_drv    drv_i;
    chnl_mon    mon_i;
    chnl_sqr    sqr_i;
	//Factory Registration
	//
    `uvm_component_utils(chnl_agt)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "chnl_agt", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual chnl_intf vif);
    extern task mon_trans();

endclass

//Constructor
function void chnl_agt::new(string name = "chnl_agt", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void chnl_agt::build_phase(uvm_phase phase);

	super.build_phase(phase);
    drv_i = chnl_drv::type_id::create("drv_i", this);
    mon_i = chnl_mon::type_id::create("mon_i", this);
    sqr_i = chnl_sqr::type_id::create("sqr_i", this);
    
endfunction

//Run_Phase
task chnl_agt::connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    drv_i.seq_item_port.connect(sqr_i.seq_item_export);
    
endtask

// User Defined Methods:
function void chnl_agt::set_interface(virtual chnl_intf vif);

    this.vif = vif;
    drv_i.set_interface(vif);
    mon_i.set_interface(vif);
    
endfunction

`endif