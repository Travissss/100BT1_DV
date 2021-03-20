//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	xx/xx/xxxx Mon 16:27
// Filename: 		xxxxxx.svh
// class Name: 		xxxxxx
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Get Virtual Interface from ENV Configuration
//	-> Drive APB Transaction on to AHB-APB Bridge
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_ARB_SV
`define MCDF_ARB_SV

class xxxxxx extends uvm_;


	
	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------

	
	//------------------------------------------
	// Sub Components
	//------------------------------------------
	
	//Factory Registration
	//

	//------------------------------------------
	// Constraints
	//------------------------------------------

	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "xxxxxx", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	// User Defined Methods:
	
endclass

//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////

//Constructor
function xxxxxx::new(string name = "xxxxxx", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void xxxxxx::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Main_Phase
task xxxxxx::main_phase(uvm_phase phase);

endtask

`endif