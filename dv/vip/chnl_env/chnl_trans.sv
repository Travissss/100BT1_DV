//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/17/2021 Wed 20:00
// Filename: 		chnl_trans.sv
// class Name: 		chnl_trans
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel transaction
//////////////////////////////////////////////////////////////////////////////////

class chnl_trans extends uvm_sequence_item;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    rand bit [31:0] data[];
    rand int        ch_id;
    rand int        pkt_id;
    rand int        data_nidles;
    rand int        ipg;
    bit             rsp;
	
	//Factory Registration
	//
    `uvm_object_utils_begin(chnl_trans)
        `uvm_field_array_int    (data       , UVM_ALL_ON)
        `uvm_field_int          (ch_id      , UVM_ALL_ON)
        `uvm_field_int          (pkt_id     , UVM_ALL_ON)
        `uvm_field_int          (data_nidles, UVM_ALL_ON)
        `uvm_field_int          (pkt_nidles , UVM_ALL_ON)
        `uvm_field_int          (rsp        , UVM_ALL_ON)   
    `uvm_object_utils_end
	//------------------------------------------
	// Constraints
	//------------------------------------------

	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "chnl_trans", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	// User Defined Methods:
	
endclass

//Constructor
function void chnl_trans::new(string name = "chnl_trans", uvm_component parent)
	super.new(name, parent);
endfunction



`endif