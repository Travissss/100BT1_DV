//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/08/2021 Mon 17:38
// Filename: 		mcdf_vsqr.sv
// class Name: 		mcdf_vsqr
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Virtual sequencer
//////////////////////////////////////////////////////////////////////////////////

class mcdf_vsqr extends uvm_sequencer;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	reg_sqr		reg_sqr;
	fmt_sqr		fmt_sqr;
	chnl_sqr	chnl_sqr[3];
	mcdf_rgm	mcdf_rgm;
	
	virtual mcdf_intf mcdf_vif;
	
	//Factory Registration
	//
	`uvm_component_utils(mcdf_vsqr)
	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_vsqr", uvm_component parent);
	// User Defined Methods:
	extern function void set_interface(virtual mcdf_intf mcdf_vif);
	
endclass

//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////
function mcdf_vsqr::new(string name = "mcdf_vsqr", uvm_component parent);
	super.new(name, this);
endfunction

function void mcdf_vsqr::set_interface(virtual mcdf_intf mcdf_vif);
	if(mcdf_vif == null)
		`uvm_error(get_type_name(), "rror in getting Interface")
	else
		this.mcdf_vif = mcdf_vif;
endfunction

