//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/25/2021 Wed 19:39
// Filename: 		fmt_trans.sv
// class Name: 		fmt_trans
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel transaction
//////////////////////////////////////////////////////////////////////////////////

class fmt_trans extends uvm_sequence_item;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    rand fmt_fifo_t         fmt_fifo;
    rand fmt_bandwidth_t    fmt_bandwidth;
    bit  [9:0]  length;
    bit  [31:0] data[];
    bit  [1:0]  ch_id;
    bit         rsp;
	
	//Factory Registration
	//
    `uvm_object_utils_begin(fmt_trans)
        `uvm_field_enum         (fmt_fifo_t     , fmt_fifo      , UVM_ALL_ON)    
        `uvm_field_enum         (fmt_bandwidth_t, fmt_bandwidth , UVM_ALL_ON) 
        `uvm_field_array_int    (data       , UVM_ALL_ON)
        `uvm_field_int    		(length     , UVM_ALL_ON)
        `uvm_field_int          (ch_id      , UVM_ALL_ON)
        `uvm_field_int          (rsp        , UVM_ALL_ON)          
    `uvm_object_utils_end
	//------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr{
        soft fmt_fifo       == MED_FIFO;
        soft fmt_bandwidth  == MED_WIDTH;
    };
	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "fmt_trans");
	
endclass

//Constructor
function fmt_trans::new(string name = "fmt_trans");
	super.new(name);
endfunction
