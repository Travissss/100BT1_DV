//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/23/2021 Thu 20:29
// Filename: 		con_sqr.sv
// class Name: 		con_sqr
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel sequencer
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CON_SQR_SV
`define MCDF_CON_SQR_SV

class con_sqr extends uvm_sequencer#(con_trans);
	
	//Factory Registration
	//
    `uvm_component_utils(con_sqr)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "con_sqr", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	
endclass

//Constructor
function con_sqr::new(string name = "con_sqr", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void con_sqr::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

`endif