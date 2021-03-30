//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/28/2021 Sun 12:42
// Filename: 		con_trans.sv
// class Name: 		con_trans
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> conv transaction
//////////////////////////////////////////////////////////////////////////////////

class con_trans extends uvm_sequence_item;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	rand bit	[32:0]	seed;
	rand bit	[1:0]	tx_mode;	//0:SEND_Z	1:SEND_I  2:SEND_N;
	rand bit	[7:0]	wait_vld;
	rand bit			master_slave;
	rand bit 			rcv_vld;
	rand bit 			rsp;
	
	bit			[1:0]	TAn;
	bit			[1:0]	TBn;
	
	//------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr{
		soft seed 			== 33'b101100000000101111010000101010000;
		soft tx_mode 		== 0;
		soft master_slave 	== 0; 
		soft wait_vld		== 10;
    };

	//Factory Registration
	//
    `uvm_object_utils_begin(con_trans)
		`uvm_field_int          (seed	  		, UVM_ALL_ON)
        `uvm_field_int          (tx_mode  		, UVM_ALL_ON)
		`uvm_field_int          (wait_vld     	, UVM_ALL_ON) 
        `uvm_field_int          (master_slave	, UVM_ALL_ON)
        `uvm_field_int          (rcv_vld     	, UVM_ALL_ON) 
        `uvm_field_int          (TAn			, UVM_ALL_ON)
        `uvm_field_int          (TBn	     	, UVM_ALL_ON) 		
    `uvm_object_utils_end
	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "con_trans");
	
endclass

//Constructor
function con_trans::new(string name = "con_trans");
	super.new(name);
endfunction

