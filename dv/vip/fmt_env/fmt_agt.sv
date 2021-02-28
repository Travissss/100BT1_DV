//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/28/2021 Wed 21:19
// Filename: 		fmt_agt.sv
// class Name: 		fmt_agt
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel agent contains monitor, sequencer, driver, connect sqr with driver
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_FMT_AGT_SV
`define MCDF_FMT_AGT_SV

class fmt_agt extends uvm_agent;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual fmt_intf vif;
    
	fmt_drv    drv_i;
    fmt_mon    mon_i;
    fmt_sqr    sqr_i;
	//Factory Registration
	//
    `uvm_component_utils(fmt_agt)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "fmt_agt", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual fmt_intf vif);

endclass

//Constructor
function void fmt_agt::new(string name = "fmt_agt", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void fmt_agt::build_phase(uvm_phase phase);

	super.build_phase(phase);
    drv_i = fmt_drv::type_id::create("drv_i", this);
    mon_i = fmt_mon::type_id::create("mon_i", this);
    sqr_i = fmt_sqr::type_id::create("sqr_i", this);
    
endfunction

//Run_Phase
task fmt_agt::connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    drv_i.seq_item_port.connect(sqr_i.seq_item_export);
    
endtask

// User Defined Methods:
function void fmt_agt::set_interface(virtual fmt_intf vif);

    this.vif = vif;
    drv_i.set_interface(vif);
    mon_i.set_interface(vif);
    
endfunction

`endif