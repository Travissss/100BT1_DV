//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/14/2021 Sun 12:55
// Filename: 		mcdf_full_random_test.sv
// class Name: 		mcdf_full_random_test
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> extends from mcdf_base_test
//////////////////////////////////////////////////////////////////////////////////

class mcdf_full_random_test extends mcdf_base_test;

	//Factory Registration
	//
	`uvm_component_utils(mcdf_full_random_test)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_full_random_test", uvm_component parent);
	// User Defined Methods:
	extern task run_top_virtual_sequence();

endclass


//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////

//Constructor
function mcdf_full_random_test::new(string name = "mcdf_full_random_test", uvm_component parent);
	
	super.new(name, parent);

endfunction

//user defined
task mcdf_full_random_test::run_top_virtual_sequence();

	mcdf_full_random_virtual_sequence	top_seq = new();
	top_seq.start(env_i.vsqr_i);

endtask



