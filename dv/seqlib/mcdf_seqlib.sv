//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/25/2021 Tue 19:13
// Filename: 		mcdf_seqlib.sv
// class Name: 		mcdf_seqlib
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Sequence library: channel sequence, formatter sequence, register sequence
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_SEQLIB_SV
`define MCDF_SEQLIB_SV
  import uvm_pkg::*;
  `include "uvm_macros.svh"

import con_pkg::*;
//////////////////////////////////////////////////////////////////////////////////
// 	-> basic sequence
//////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////
// 	-> sequence for channel data read
//////////////////////////////////////////////////////////////////////////////////
class chnl_data_sequence extends uvm_sequence#(chnl_trans);
	
    //------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    rand int        ch_id       = -1;
    int				pkt_id      = 0;
    rand int        data_nidles = -1;
    rand int        pkt_nidles  = -1;
    rand int        data_size   = -1;
    rand int        ntrans      = 10;
    
	
	//Factory Registration
	//
    `uvm_object_utils_begin(chnl_data_sequence)
        `uvm_field_int          (ch_id      , UVM_ALL_ON)
        `uvm_field_int          (pkt_id     , UVM_ALL_ON)
        `uvm_field_int          (data_nidles, UVM_ALL_ON)
        `uvm_field_int          (pkt_nidles , UVM_ALL_ON)
        `uvm_field_int          (data_size  , UVM_ALL_ON) 
        `uvm_field_int          (ntrans     , UVM_ALL_ON)         
    `uvm_object_utils_end    
    //There is no need to use p_sequencer here
    //`uvm_declare_p_sequencer(chnl_sequencer)
	

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "chnl_data_sequence");
		super.new(name);
	endfunction

	virtual task body();
		int ntrans_int = 0;
        repeat(ntrans) begin 
			send_trans();
			ntrans_int++;
		end
    endtask
	
	task send_trans();
        chnl_trans req, rsp;
		`uvm_do_with(req, {	local::ch_id       >= 0 -> ch_id        == local::ch_id;    
							pkt_id       == local :: pkt_id;     
							//local::pkt_id      >= 0 -> pkt_id       == local::pkt_id;     
							local::data_nidles >= 0 -> data_nidles	== local::data_nidles;
							local::pkt_nidles  >= 0 -> pkt_nidles 	== local::pkt_nidles; 
							local::data_size   >= 0 -> data_size 	== local::data_size;
							})
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
        s = {s, super.sprint()};
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
    `uvm_object_utils_begin(fmt_config_sequence)
        `uvm_field_enum (fmt_fifo_t     , fifo      , UVM_ALL_ON)
        `uvm_field_enum (fmt_bandwidth_t, bandwidth , UVM_ALL_ON)        
    `uvm_object_utils_end
    
    //There is no need to use p_sequencer here
    //`uvm_declare_p_sequencer(chnl_sequencer)
	
    //------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr_fmt{
        soft fifo == MED_FIFO;
        soft bandwidth == MED_WIDTH;
    }
    

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
        fmt_trans req, rsp;
		`uvm_do_with(req, {	local::fifo != MED_FIFO         -> fifo == local::fifo;    
							local::bandwidth != MED_WIDTH   -> bandwidth == local::bandwidth;     							
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
        s = {s, super.sprint()};
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
	rand bit [31:0]	loc_low_timer;
	rand bit [31:0]	loc_high_timer;
    
	
	//Factory Registration
	//
    `uvm_object_utils_begin(reg_base_sequence)
        `uvm_field_int          (cmd    		, UVM_ALL_ON)
        `uvm_field_int          (addr   		, UVM_ALL_ON)
        `uvm_field_int          (data   		, UVM_ALL_ON)  
		`uvm_field_int			(loc_low_timer	, UVM_ALL_ON)
		`uvm_field_int			(loc_high_timer	, UVM_ALL_ON)		
    `uvm_object_utils_end
    
    //There is no need to use p_sequencer here
    //`uvm_declare_p_sequencer(reg_sqr)
	
    //------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr_reg_base{
        soft addr   == -1;
        soft cmd    == -1;
        soft data   == -1;    
		soft loc_low_timer 	== -1;
		soft loc_high_timer == -1;
    }

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "reg_base_sequence");
		super.new(name);
	endfunction

	task body();
    
        send_trans();
	
    endtask
	
	task send_trans();
        reg_trans req, rsp;
		`uvm_do_with(req, {	local:: cmd  >= 0 ->  cmd   == local:: cmd ;
							local:: addr >= 0 ->  addr  == local:: addr;
							local:: data >= 0 ->  data	== local:: data;	
							local:: loc_low_timer >= 0 ->loc_low_timer == local:: loc_low_timer;
							local:: loc_high_timer>= 0 ->loc_high_timer== local:: loc_high_timer;
							})                           
        `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
        get_response(rsp);
        `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
        if(req.cmd == `READ)
            this.data = rsp.data;
        assert(rsp.rsp)
            else `uvm_error("[rsp error] %0t error response received\n", $time )
    endtask
    
    function void post_randomize();
        string s;
        s = {s, "After Randomizztion \n"};
        s = {s, "##############################\n"};
        s = {s, "reg_base_sequence trans content: \n"};
        s = {s, super.sprint()};
        s = {s, "##############################\n"};
        `uvm_info(get_type_name(), s, UVM_MEDIUM)
    endfunction
	
endclass

//////////////////////////////////////////////////////////////////////////////////
// 	-> IDLE sequence for register
//////////////////////////////////////////////////////////////////////////////////
class reg_idle_sequence extends reg_base_sequence;
        //------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr{
        data    == 0;
        addr    == 0;
        cmd     == `IDLE;   
		loc_low_timer	== 2;
		loc_high_timer 	== 18;
    };
    
    
    //Factory Registration
	//
	`uvm_object_utils(reg_idle_sequence)
    
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "reg_idle_sequence");
		super.new(name);
	endfunction
    

endclass
    
//////////////////////////////////////////////////////////////////////////////////
// 	-> READ sequence for register
//////////////////////////////////////////////////////////////////////////////////
class reg_read_sequence extends reg_base_sequence;
        //------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr{
        cmd     == `READ;          
    };
    
    
    //Factory Registration
	//
	`uvm_object_utils(reg_read_sequence)
    
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "reg_read_sequence");
		super.new(name);
	endfunction
    

endclass

//////////////////////////////////////////////////////////////////////////////////
// 	-> WRITE sequence for register
//////////////////////////////////////////////////////////////////////////////////
class reg_write_sequence extends reg_base_sequence;
        //------------------------------------------
	// Constraints
	//------------------------------------------
    constraint cstr{
        cmd     == `WRITE;          
    };
    
    
    //Factory Registration
	//
	`uvm_object_utils(reg_write_sequence)
    
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "reg_write_sequence");
		super.new(name);
	endfunction
    

endclass

//////////////////////////////////////////////////////////////////////////////////
// 	-> sequence for converter
//	->
//	->
//	->
//////////////////////////////////////////////////////////////////////////////////
class con_base_sequence extends uvm_sequence #(con_trans);
    //------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	rand bit [32:0]	seed 			= -1;
	rand bit [1:0]	tx_mode 		= -1;	//0:SEND_Z	1:SEND_I  2:SEND_N;
	rand bit [7:0]	wait_vld 		= -1;
	rand bit 		master_slave 	= -1;
	
	//Factory Registration
	//
    `uvm_object_utils_begin(con_base_sequence)
        `uvm_field_int          (seed      		, UVM_ALL_ON)
        `uvm_field_int          (tx_mode     	, UVM_ALL_ON)
        `uvm_field_int          (wait_vld		, UVM_ALL_ON)
        `uvm_field_int          (master_slave	, UVM_ALL_ON)      
    `uvm_object_utils_end    

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "con_base_sequence");
		super.new(name);
	endfunction

	virtual task body();
	
			send_trans();
    
	endtask
	
	task send_trans();
        con_trans req,rsp;
		`uvm_do_with(req, {	local::seed       	>= 0 -> seed    	== local::seed;    
							local::tx_mode 		>= 0 -> tx_mode		== local::tx_mode;
							local::wait_vld  	>= 0 -> wait_vld	== local::wait_vld; 
							local::master_slave >= 0 -> master_slave== local::master_slave;
							})
        get_response(rsp);
        `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
        assert(rsp.rsp)
            else `uvm_error("[rsp error] %0t error response received", $time )
    endtask
    
    function void post_randomize();
        string s;
        s = {s, "After Randomizztion \n"};
        s = {s, "##############################\n"};
        s = {s, "con_base_sequence trans content: \n"};
        s = {s, super.sprint()};
        s = {s, "##############################\n"};
        `uvm_info(get_type_name(), s, UVM_MEDIUM)
    endfunction
		
endclass

 
`endif
