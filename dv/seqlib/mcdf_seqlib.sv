//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/25/2021 Tue 19:13
// Filename: 		mcdf_seqlib.sv
// class Name: 		mcdf_seqlib
// Project Name: 	ahb2apb_bridge
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> ahbl sequence library
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_SEQLIB_SV
`define MCDF_SEQLIB_SV


//////////////////////////////////////////////////////////////////////////////////
// 	-> basic sequence
//////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////
// 	-> sequence for channel data read
//////////////////////////////////////////////////////////////////////////////////
class chnl_data_sequence extends uvm_sequence #(chnl_trans);
	
    //------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    rand int        ch_id       = -1;
    rand int        pkt_id      = 0;
    rand int        data_nidles = -1;
    rand int        pkt_nidles  = -1;
    rand int        data_size   = -1;
    rand int        ntrans      = -1;
    
	
	//Factory Registration
	//
    `uvm_object_utils_begin(chnl_trans)
        `uvm_field_int          (ch_id      , UVM_ALL_ON)
        `uvm_field_int          (pkt_id     , UVM_ALL_ON)
        `uvm_field_int          (data_nidles, UVM_ALL_ON)
        `uvm_field_int          (pkt_nidles , UVM_ALL_ON)
        `uvm_field_int          (data_size  , UVM_ALL_ON) 
        `uvm_field_int          (ntrans     , UVM_ALL_ON)         
    `uvm_object_utils_end
    
    //There is no need to use p_sequencer here
    //`uvm_declare_p_sequencer(chnl_sequencer)
	
    //Factory Registration
	//
	`uvm_object_utils(chnl_data_sequence)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "chnl_data_sequence");
		super.new(name);
	endfunction

	virtual task body();
    
        repeat(ntrans) send_trans();
	
    endtask
	
	task send_trans();
        chnl_trans req, rsp;
		`uvm_do_with(req, {	local::ch_id       >= 0 -> ch_id        == local::ch_id;    
							local::pkt_id      >= 0 -> pkt_id       == local::pkt_id;     
							local::data_nidles >= 0 -> data_nidles	== local::data_nidles;
							local::pkt_nidles  >= 0 -> pkt_nidles 	== local::pkt_nidles; 
							local::data_size   >= 0 -> data.size() 	== local::data_size;})
        this.pkt_id++;
        `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
        get_response(rsp);
        `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
        assert(rsp.rsp)
            else `uvm_error("[rsp error] %0t error response received", $time )
    endtask
    
    function void post_randomize();
        string s;
        s = {s, "After Randomizztion \n"};
        s = {s, "##############################\n"};
        s = {s, "chnl_data_sequence trans content: \n"};
        s = {s,sprint()};
        s = {s, "##############################\n"};
        `uvm_info(get_type_name(), s, UVM_MEDIUM)
    endfunction
		
endclass


//////////////////////////////////////////////////////////////////////////////////
// 	-> sequence for formatter 
//////////////////////////////////////////////////////////////////////////////////

class fmt_config_sequence extends uvm_sequence#(fmt_trans);
	
    //------------------------------------------
	// Data, Interface, port  Members : following is some stupid codes, why use soft constraints here? non sense
	//------------------------------------------
    rand fmt_fifo_t         fifo = MED_FIFO;
    rand fmt_bandwidth_t    bandwidth = MED_WIDTH;
    
	
	//Factory Registration
	//
    `uvm_object_utils_begin(fmt_trans)
        `uvm_field_enum (fmt_fifo_t     , fifo      , UVM_ALL_ON)
        `uvm_field_enum (fmt_bandwidth_t, bandwidth , UVM_ALL_ON)        
    `uvm_object_utils_end
    
    //There is no need to use p_sequencer here
    //`uvm_declare_p_sequencer(chnl_sequencer)
	
    //Factory Registration
	//
	`uvm_object_utils(fmt_config_sequence)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "fmt_config_sequence");
		super.new(name);
	endfunction

	virtual task body();
    
        send_trans();
	
    endtask
	
	task send_trans();
        chnl_trans req, rsp;
		`uvm_do_with(req, {	local::fifo != MED_FIFO         -> fifo == local::fifo;    
							local::bandwidth != MED_WIDTH   -> bandwidth == local::pkt_id;     							
							})
                            
        `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
        get_response(rsp);
        `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
        assert(rsp.rsp)
            else `uvm_error("[rsp error] %0t error response received", $time )
    endtask
    
    function void post_randomize();
        string s;
        s = {s, "After Randomizztion \n"};
        s = {s, "##############################\n"};
        s = {s, "fmt_config_sequence trans content: \n"};
        s = {s,sprint()};
        s = {s, "##############################\n"};
        `uvm_info(get_type_name(), s, UVM_MEDIUM)
    endfunction
		
endclass


//////////////////////////////////////////////////////////////////////////////////
// 	-> sequence for register as base sequence
//////////////////////////////////////////////////////////////////////////////////
class reg_base_sequence extends uvm_sequence #(reg_trans);
	
    //------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    rand bit [1:0]  cmd = -1;
    rand bit [7:0]  addr= -1;
    rand bit [31:0] data= -1;

    
	
	//Factory Registration
	//
    `uvm_object_utils_begin(chnl_trans)
        `uvm_field_int          (cmd    , UVM_ALL_ON)
        `uvm_field_int          (addr   , UVM_ALL_ON)
        `uvm_field_int          (data   , UVM_ALL_ON)        
    `uvm_object_utils_end
    
    //There is no need to use p_sequencer here
    //`uvm_declare_p_sequencer(chnl_sequencer)
	
    //Factory Registration
	//
	`uvm_object_utils(chnl_data_sequence)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "chnl_data_sequence");
		super.new(name);
	endfunction

	virtual task body();
    
        repeat(ntrans) send_trans();
	
    endtask
	
	task send_trans();
        chnl_trans req, rsp;
		`uvm_do_with(req, {	local:: cmd  >= 0 ->  cmd   == local:: cmd ;
							local:: addr >= 0 ->  addr  == local:: addr;
							local:: data >= 0 ->  data	== local:: data;	})                           
        `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
        get_response(rsp);
        `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
        if(this.cmd == `READ)
            this.data = rsp.data;
        assert(rsp.rsp)
            else `uvm_error("[rsp error] %0t error response received", $time )
    endtask
    
    function void post_randomize();
        string s;
        s = {s, "After Randomizztion \n"};
        s = {s, "##############################\n"};
        s = {s, "chnl_data_sequence trans content: \n"};
        s = {s,sprint()};
        s = {s, "##############################\n"};
        `uvm_info(get_type_name(), s, UVM_MEDIUM)
    endfunction
		
endclass

`endif
