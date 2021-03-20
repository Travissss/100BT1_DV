//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/02/2021 Tue 21:18 
// Filename: 		reg_agt.sv
// class Name: 		reg_agt
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> register agent contains monitor, sequencer, driver, connect sqr with driver
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_REG_AGT_SV
`define MCDF_REG_AGT_SV

class reg_agt extends uvm_agent;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual reg_intf vif;
    
	reg_drv    drv_i;
    reg_mon    mon_i;
    reg_sqr    sqr_i;
	//Factory Registration
	//
    `uvm_component_utils(reg_agt)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "reg_agt", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual reg_intf vif);

endclass

//Constructor
function reg_agt::new(string name = "reg_agt", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void reg_agt::build_phase(uvm_phase phase);

	super.build_phase(phase);
    drv_i = reg_drv::type_id::create("drv_i", this);
    mon_i = reg_mon::type_id::create("mon_i", this);
    sqr_i = reg_sqr::type_id::create("sqr_i", this);
    
endfunction

//Connect_Phase
function void reg_agt::connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    drv_i.seq_item_port.connect(sqr_i.seq_item_export);
    
endfunction

// User Defined Methods:
function void reg_agt::set_interface(virtual reg_intf vif);

    this.vif = vif;
    drv_i.set_interface(vif);
    mon_i.set_interface(vif);
	
endfunction

`endif