//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/28/2021 Sun 15:04
// Filename: 		con_agt.sv
// class Name: 		con_agt
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> converter's agent contains monitor, sequencer, driver, connect sqr with driver
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CON_AGT_SV
`define MCDF_CON_AGT_SV

class con_agt extends uvm_agent;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual con_intf vif;
    
	con_drv    drv_i;
    con_mon    mon_i;
    con_sqr    sqr_i;
	//Factory Registration
	//
    `uvm_component_utils(con_agt)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "con_agt", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual con_intf vif);

endclass

//Constructor
function con_agt::new(string name = "con_agt", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void con_agt::build_phase(uvm_phase phase);

	super.build_phase(phase);
    drv_i = con_drv::type_id::create("drv_i", this);
    mon_i = con_mon::type_id::create("mon_i", this);
    sqr_i = con_sqr::type_id::create("sqr_i", this);
    
endfunction

//Run_Phase
function void con_agt::connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    drv_i.seq_item_port.connect(sqr_i.seq_item_export);
    
endfunction

// User Defined Methods:
function void con_agt::set_interface(virtual con_intf vif);

    this.vif = vif;
    drv_i.set_interface(vif);
    mon_i.set_interface(vif);
    
endfunction

`endif