//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/26/2021 Thu 
// Filename: 		fmt_sqr.sv
// class Name: 		fmt_sqr
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> formatter sequencer
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_FMT_SQR_SV
`define MCDF_FMT_SQR_SV

class fmt_sqr extends uvm_sequencer#(fmt_trans);
	
	//Factory Registration
	//
    `uvm_component_utils(fmt_sqr)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "fmt_sqr", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	
endclass

//Constructor
function void fmt_sqr::new(string name = "fmt_sqr", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void fmt_sqr::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

`endif