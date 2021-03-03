//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/02/2021 Tue 21:18 
// Filename: 		reg_agent.sv
// class Name: 		reg_agent
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> register agent contains monitor, sequencer, driver, connect sqr with driver
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_REG_AGT_SV
`define MCDF_REG_AGT_SV

class reg_agent extends uvm_agent;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual reg_intf vif;
    
	fmt_drv    drv_i;
    fmt_mon    mon_i;
    fmt_sqr    sqr_i;
	//Factory Registration
	//
    `uvm_component_utils(reg_agent)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "reg_agent", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual reg_intf vif);

endclass

//Constructor
function void reg_agent::new(string name = "reg_agent", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void reg_agent::build_phase(uvm_phase phase);

	super.build_phase(phase);
    drv_i = fmt_drv::type_id::create("drv_i", this);
    mon_i = fmt_mon::type_id::create("mon_i", this);
    sqr_i = fmt_sqr::type_id::create("sqr_i", this);
    
endfunction

//Connect_Phase
task reg_agent::connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    drv_i.seq_item_port.connect(sqr_i.seq_item_export);
    
endtask

// User Defined Methods:
function void reg_agent::set_interface(virtual reg_intf vif);

    this.vif = vif;
    drv_i.set_interface(vif);
    mon_i.set_interface(vif);
    
endfunction

`endif