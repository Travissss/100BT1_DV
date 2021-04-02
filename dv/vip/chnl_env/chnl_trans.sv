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
    rand bit [7:0] data[];
    rand bit [3:0] pkt_data;
    rand bit [31:0] data_size;
    rand int        ch_id;
    rand int        pkt_id;
    rand int        data_nidles;
    rand int        pkt_nidles;
    bit             rsp;
	
	//------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr{
        //soft data_size inside {[4:32]};
		soft data.size() == data_size;
		
        soft ch_id == 0;
        soft pkt_id == 0;
        soft data_nidles inside {[0:2]};
        soft pkt_nidles inside {[1:10]};
		foreach(data[i]) data[i] == (this.ch_id << 6) + (pkt_data<<2)+ i;
    };

	//Factory Registration
	//
    `uvm_object_utils_begin(chnl_trans)
        `uvm_field_array_int    (data       , UVM_ALL_ON)
        `uvm_field_int			(pkt_data   , UVM_ALL_ON)
        `uvm_field_int          (data_size  , UVM_ALL_ON)
        `uvm_field_int          (ch_id      , UVM_ALL_ON)
        `uvm_field_int          (pkt_id     , UVM_ALL_ON)
        `uvm_field_int          (data_nidles, UVM_ALL_ON)
        `uvm_field_int          (pkt_nidles , UVM_ALL_ON)
        `uvm_field_int          (rsp        , UVM_ALL_ON)   
    `uvm_object_utils_end
	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "chnl_trans");
	
endclass

//Constructor
function chnl_trans::new(string name = "chnl_trans");
	super.new(name);
endfunction

