//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/14/2021 Sun 12:21
// Filename: 		mcdf_data_consistence_basic_test.sv
// class Name: 		mcdf_data_consistence_basic_test
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> extends from mcdf_base_test
//////////////////////////////////////////////////////////////////////////////////

class mcdf_data_consistence_basic_test extends mcdf_base_test;

	//Factory Registration
	//
	`uvm_component_utils(mcdf_data_consistence_basic_test)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_data_consistence_basic_test", uvm_component parent);
	// User Defined Methods:
	extern task run_top_virtual_sequence();

endclass


//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////

//Constructor
function mcdf_data_consistence_basic_test::new(string name = "mcdf_data_consistence_basic_test", uvm_component parent);
	
	super.new(name, parent);

endfunction

//user defined
task mcdf_data_consistence_basic_test::run_top_virtual_sequence();
	mcdf_data_consistence_basic_virtual_sequence top_seq = new();
	top_seq.start(env_i.vsqr_i);
//	int seq_num;
//	chnl_data_sequence top_seq = new();
//	begin
//		seq_num = 0;
//		while(1)begin
//		top_seq.start(env_i.vsqr_i);
//		seq_num++;
//		if(seq_num >= 20)
//			break;
//		end
//	end
endtask



