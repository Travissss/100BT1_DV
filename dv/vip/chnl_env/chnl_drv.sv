//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/17/2021 Wed 20:03
// Filename: 		chnl_drv.sv
// class Name: 		chnl_drv
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel driver
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CHNL_DRV_SV
`define MCDF_CHNL_DRV_SV

class chnl_drv extends uvm_driver;


	
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
	extern function new(string name = "chnl_drv", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	// User Defined Methods:
	
endclass

//Constructor
function void chnl_drv::new(string name = "chnl_drv", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void chnl_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Main_Phase
task chnl_drv::main_phase(uvm_phase phase);

endtask

`endif