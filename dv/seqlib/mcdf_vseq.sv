//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/13/2021 Sun 17:13
// Filename: 		mcdf_vseq.sv
// class Name: 		mcdf_vseq
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Virtual Sequence library: base, consistence, full random, built in
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_VSEQ_SV
`define MCDF_VSEQ_SV


//////////////////////////////////////////////////////////////////////////////////
// 	-> basic sequence
//////////////////////////////////////////////////////////////////////////////////
class mcdf_base_virtual_sequence extends uvm_sequence;
	reg_idle_sequence	reg_idle_seq;
	reg_write_sequence	reg_write_seq;
	reg_read_sequence	reg_read_seq
	chnl_data_sequence	chnl_data_seq;
	fmt_config_sequence	fmt_config_seq;
	mcdf_rgm			rgm;
	
	`uvm_object_utils(mcdf_base_virtual_sequence)
	`uvm_declare_p_sequencer(mcdf_virtual_sequencer)
	
	function new(string name = "mcdf_base_virtual_sequence";)
		super.new(name);
	endfunction
	
	virtual task body();
		`uvm_info(get_type_name(),"=====================STARTED=====================", UVM_LOW)
		rgm = p_sequencer.mcdf_rgm;
		
		this.do_reg();
		this.do_formatter();
		this.do_data();
		`uvm_info(get_type_name(),"=====================FINISHED=====================", UVM_LOW)
	endtask
	
	//do register configuration
	virtual task do_reg();
	
	endtask

	//
	virtual task do_formatter();
	
	endtask

	//do data transition form 3 channel slaves
	virtual task do_data();
	
	endtask	
	
	virtual function bit diff_value(int val1, int val2, string id = "value_compare");
		if(val1 != val2) begin
			`uvm_error("compare error", $sformatf("Error! %s val1 %8x != val2 %8x", id, val1, val2))
			return 0;
		end else begin
			`uvm_error("compare success", $sformatf("Success! %s val1 %8x == val2 %8x", id, val1, val2))
			return 0;		
		end
	endfunction
	
endclass
//////////////////////////////////////////////////////////////////////////////////
// 	-> child virtual sequences
//////////////////////////////////////////////////////////////////////////////////
class mcdf_data_consistence_basic_virtual_sequence extends mcdf_base_virtual_sequence;
	
	//Factory Registration
	//
    `uvm_object_utils(mcdf_data_consistence_basic_virtual_sequence)
  
    //There is no need to use p_sequencer here
    //`uvm_declare_p_sequencer(chnl_sequencer)
	

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "mcdf_data_consistence_basic_virtual_sequence");
		super.new(name);
	endfunction

	virtual task body();
    
        repeat(ntrans) send_trans();
	
    endtask
	
	//user defined, extends from base sequence
	//do register configuration
	virtual task do_reg();
		bit [31:0] 		wr_val, rd_val;
		uvm_status_e	status;
		//slv0 with len = 8, prio = 0, en = 1;
		wr_val = (1 << 3) + (0 << 1) + 1;
		rgm.chnl0_ctrl_reg.write(status, wr_val);
		rgm.chnl0_ctrl_reg.read(status, rd_val);
		void'(this.diff_value(wr_val, rd_val, "SLV0_WR_REG"));
		
		//slv1 with len = 16, prio = 1, en = 1;
		wr_val = (2 << 3) + (1 << 1) + 1;
		rgm.chnl1_ctrl_reg.write(status, wr_val);
		rgm.chnl1_ctrl_reg.read(status, rd_val);
		void'(this.diff_value(wr_val, rd_val, "SLV1_WR_REG"));
		
		//slv2 with len = 32, prio = 1, en = 1;
		wr_val = (3 << 3) + (1 << 1) + 1;
		rgm.chnl2_ctrl_reg.write(status, wr_val);
		rgm.chnl2_ctrl_reg.read(status, rd_val);
		void'(this.diff_value(wr_val, rd_val, "SLV2_WR_REG"));
		
		//send idle command
		`uvm_do_on(idle_reg_seq, p_sequencer.reg_sqr)
	endtask

	//
	virtual task do_formatter();
	
		`uvm_do_on_with(fmt_config_seq, p_sequencer.fmt_sqr, {	fifo 		== LONG_FIFO;
																bandwidth	== HIGH_WIDTH;})
	
	endtask

	//do data transition form 3 channel slaves
	virtual task do_data();
		fork
			`uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[0], {	ntrans		== 100;
																		ch_id		== 0;
																		data_nidles	== 0;
																		pkt_nidles 	== 1;
																		data_size	== 8;})
																		
			`uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], {	ntrans		== 100;
																		ch_id		== 1;
																		data_nidles	== 1;
																		pkt_nidles 	== 4;
																		data_size	== 16;})
																		
			`uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[2], {	ntrans		== 100;
																		ch_id		== 2;
																		data_nidles	== 2;
																		pkt_nidles 	== 1;
																		data_size	== 32;})
		
		join
		#10ns;	//wait until all data transition finished
	endtask			
endclass

//////////////////////////////////////////////////////////////////////////////////
// 	-> prio, enable, length are full random
//////////////////////////////////////////////////////////////////////////////////
class mcdf_full_random_virtual_sequence extends mcdf_base_virtual_sequence;
	
	//Factory Registration
	//
    `uvm_object_utils(mcdf_full_random_virtual_sequence)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "mcdf_full_random_virtual_sequence");
		super.new(name);
	endfunction
	
	//user defined, extends from base sequence
	//do register configuration
	virtual task do_reg();
		bit [31:0]		ch0_wr_val;
		bit [31:0]		ch1_wr_val;
		bit [31:0]		ch2_wr_val;
		uvm_status_e	status;
		
		//reset uvm_reg_block: a built in task reset()
		rgm.reset();
		
		//slv channel with length = {4, 8, 16, 32}, prio = {[0:3]}, en = {[0:1]}
		ch0_wr_val = ($urandom_range(0,3) << 3) + ($urandom_range(0,3) << 1) + $urandom_range(0,1);
		ch1_wr_val = ($urandom_range(0,3) << 3) + ($urandom_range(0,3) << 1) + $urandom_range(0,1);
		ch2_wr_val = ($urandom_range(0,3) << 3) + ($urandom_range(0,3) << 1) + $urandom_range(0,1);
		
		//set all desired value of WR register via uvm_reg::set()
		rgm.chnl0_ctrl_reg.set(ch0_wr_val);
		rgm.chnl1_ctrl_reg.set(ch1_wr_val);
		rgm.chnl2_ctrl_reg.set(ch2_wr_val);
		
		//update them via uvm_reg_block::update()
		rgm.update(status);
		
		//wait until the registers in DUT have been updated
		#100ns;
		
		//compare desired value and mirror value
		rgm.chnl0_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
		rgm.chnl1_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
		rgm.chnl2_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
		
		//send idle command
		`uvm_do_on(idle_reg_seq, p_sequencer.reg_sqr, )
	endtask

	//
	virtual task do_formatter();
		`uvm_do_on_with(fmt_config_seq, p_sequencer.fmt_sqr, 
			{	fifo inside {SHORT_FIFO, ULTRA_FIFO};
				bandwidth == HIGH_WIDTH;})
	endtask
	//do data transition form 3 channel slaves
	virtual task do_data();
		fork
			`uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[0], 
			{	ntrans inside {[400:600]};
				ch_id==0; 
				data_nidles inside {[0:3]};
				pkt_nidles inside {1,2,4,8}; 
				data_size inside {8,16,32};})
				
			`uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], 
			{	ntrans 		inside {[400:600]}; 
				ch_id==0; 
				data_nidles inside {[0:3]}; 
				pkt_nidles 	inside {1,2,4,8}; 
				data_size 	inside {8,16,32};})
				
			`uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], 
			{	ntrans 		inside {[400:600]}; 
				ch_id==0; 
				data_nidles inside {[0:3]}; 
				pkt_nidles 	inside {1,2,4,8}; 
				data_size 	inside {8,16,32};})
		join
		#10ns
	endtask	
    

endclass
//////////////////////////////////////////////////////////////////////////////////
// 	-> built in sequence
//		-uvm_reg_hw_reset_seq
//  	-uvm_reg_bit_bash_seq
//  	-uvm_reg_access_seq
//////////////////////////////////////////////////////////////////////////////////

class mcdf_reg_builtin_virtual_sequence extends mcdf_base_virtual_sequence;
	
	//Factory Registration
	//
    `uvm_object_utils(mcdf_reg_builtin_virtual_sequence)

	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	function new(string name = "mcdf_reg_builtin_virtual_sequence");
		super.new(name);
	endfunction
	
	//user defined, extends from base sequence
	//do register configuration
	virtual task do_reg();
		uvm_reg_hw_reset_seq	reg_rst_seq 		= new();
		uvm_reg_bit_bash_seq	reg_bit_base_seq 	= new();
		uvm_reg_access_seq		reg_acc_seq			= new();
		
		//wait reset asserted and release
		@(negedge p_sequencer.mcdf_vif.rstn);
		@(posedge p_sequencer.mcdf_vif.rstn);
		
		//reset sequence
		`uvm_info("Built in SEQ", "register reset sequence started", UVM_LOW)
		rgm.reset();
		reg_rst_seq.model = rgm;
		reg_rst_seq.start(p_sequencer.reg_sqr);
		`uvm_info("Built in SEQ", "register reset sequence finished", UVM_LOW)	
						
		//reg sequence check read and write domain
		`uvm_info("Built in SEQ", "register bit bash sequence started", UVM_LOW)
		p_sequencer.mcdf_vif.rstn <= 'b0;
		repeat(5) @(posedge p_sequencer.mcdf_vif.clk);
		p_sequencer.mcdf_vif.rstn <= 'b1;
		rgm.reset();
		reg_bit_base_seq.model = rgm;
		reg_bit_base_seq.start(p_sequencer.reg_sqr);
		`uvm_info("Built in SEQ", "register bit bash sequence finished", UVM_LOW)			
		
		// reset hardware register and register model
		p_sequencer.intf.rstn <= 'b0;
		repeat(5) @(posedge p_sequencer.intf.clk);
		p_sequencer.intf.rstn <= 'b1;
		rgm.reset();
		reg_acc_seq.model = rgm;
		reg_acc_seq.start(p_sequencer.reg_sqr);
		`uvm_info("BLTINSEQ", "register access sequence finished", UVM_LOW)
		
	endtask
 
endclass





 
`endif
