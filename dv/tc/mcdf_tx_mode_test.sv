//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	04/02/2021 Fri 12:21
// Filename: 		mcdf_tx_mode_test.sv
// class Name: 		mcdf_tx_mode_test
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> extends from mcdf_base_test
//////////////////////////////////////////////////////////////////////////////////

class mcdf_tx_mode_test extends mcdf_base_test;

	//Factory Registration
	//
	`uvm_component_utils(mcdf_tx_mode_test)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_tx_mode_test", uvm_component parent);
	// User Defined Methods:
	extern task run_top_virtual_sequence();

endclass


//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////

//Constructor
function mcdf_tx_mode_test::new(string name = "mcdf_tx_mode_test", uvm_component parent);
	
	super.new(name, parent);

endfunction

//user defined
task mcdf_tx_mode_test::run_top_virtual_sequence();
	phy_tx_mode_virtual_sequence top_seq = new();
	top_seq.start(env_i.vsqr_i);

endtask



