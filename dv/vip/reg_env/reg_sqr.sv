//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/02/2021 Tue 21:18 
// Filename: 		reg_sqr.sv
// class Name: 		reg_sqr
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> register sequencer
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_REG_SQR_SV
`define MCDF_REG_SQR_SV

class reg_sqr extends uvm_sequencer#(fmt_trans);
	
	//Factory Registration
	//
    `uvm_component_utils(reg_sqr)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "reg_sqr", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	
endclass

//Constructor
function void reg_sqr::new(string name = "reg_sqr", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void reg_sqr::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

`endif