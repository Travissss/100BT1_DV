//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/02/2021 Tue 20:55
// Filename: 		reg_trans.sv
// class Name: 		reg_trans
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> register transaction
//////////////////////////////////////////////////////////////////////////////////

class reg_trans extends uvm_sequence_item;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	rand bit	[1:0]   cmd;
	rand bit	[7:0]   addr;    
	rand bit	[31:0]	data;
	bit					rsp;
    
	//Factory Registration
	//
    `uvm_object_utils_begin(reg_trans)
        `uvm_field_int(cmd  , UVM_ALL_ON)
        `uvm_field_int(addr , UVM_ALL_ON)
        `uvm_field_int(data , UVM_ALL_ON)
        `uvm_field_int(rsp  , UVM_ALL_ON)
    `uvm_object_utils_end
	//------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr{
        soft cmd    inside {`WRITE, `READ, `IDLE};
        soft addr   inside {`SLV0_RW_ADDR, `SLV1_RW_ADDR, `SLV2_RW_ADDR, `SLV0_R_ADDR, `SLV1_R_ADDR, `SLV2_R_ADDR};
        soft addr[7:5] == 0;
        addr[4] == 1 -> soft cmd == `READ;
        (addr[7:4] == 0 && cmd == `WRITE) -> soft data[31:6] == 0;      
    };
	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "reg_trans");
	
endclass

//Constructor
function reg_trans::new(string name = "reg_trans");
	super.new(name);
endfunction
