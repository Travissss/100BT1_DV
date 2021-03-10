//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/06/2021 Sat 14:40 
// Filename: 		mcdf_scb.sv
// class Name: 		mcdf_scb
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> mcdf reference model
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_SCB_SV
`define MCDF_SCB_SV

//for scoreboard connect with different imp
`uvm_blocking_put_imp_decl(_chnl0)
`uvm_blocking_put_imp_decl(_chnl1)
`uvm_blocking_put_imp_decl(_chnl2)
`uvm_blocking_put_imp_decl(_reg)
`uvm_blocking_put_imp_decl(_fmt)

`uvm_blocking_get_peek_imp_decl(_chnl0)
`uvm_blocking_get_peek_imp_decl(_chnl1)
`uvm_blocking_get_peek_imp_decl(_chnl2)
`uvm_blocking_get_imp_decl(_reg)

class mcdf_scb extends uvm_component;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    local int 	err_cnt;
	local int	total_cnt;
	local int	chnl_cnt[3];
	
	local virtual chnl_intf	chnl_vifs[3];
	local virtual arb_intf	arb_vif;
	local virtual mcdf_intf	mcdf_vif
	local mcdf_refmod		refmod;
    
	//connect with channel monitor, formatter monitor and register monitor
    uvm_blocking_put_imp_chnl0 		#(mon_data_t, mcdf_scb)	chnl0_bp_imp;
	uvm_blocking_put_imp_chnl1 		#(mon_data_t, mcdf_scb)	chnl1_bp_imp;
	uvm_blocking_put_imp_chnl2 		#(mon_data_t, mcdf_scb)	chnl2_bp_imp;
	uvm_blocking_put_imp_fmt 		#(fmt_trans	, mcdf_scb)	fmt_bp_imp;
	uvm_blocking_put_imp_reg		#(reg_trans	, mcdf_scb)	reg_bp_imp;
	//connect with reference model port
	uvm_blocking_get_peek_imp_chnl0 #(mon_data_t, mcdf_scb)	chnl0_bgpk_imp;
	uvm_blocking_get_peek_imp_chnl1 #(mon_data_t, mcdf_scb)	chnl1_bgpk_imp;
	uvm_blocking_get_peek_imp_chnl2 #(mon_data_t, mcdf_scb)	chnl2_bgpk_imp;
    //connect with reference model reg port
	uvm_blocking_get_imp_reg		#(reg_trans	, mcdf_scb)	reg_bg_imp;
	//connect with reference model uvm_tlm_fifo
	uvm_blocking_get_port			#(fmt_trans	, mcdf_scb)	exp_bg_port;
	
	//mailbox definition for imp method
	mailbox #(mon_data_t) 	chnl_mbs[3];
	mailbox #(fmt_trans)	fmt_mb;
	mailbox #(reg_trans)	reg_mb;
	//Factory Registration
	//
    `uvm_component_utils(mcdf_scb)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_scb", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task report_phase(uvm_phase phase);
	
	// User Defined Methods:
    extern virtual function void set_interface(virtual mcdf_intf vif);
    extern task do_channel_disable_check(int id);
    extern task do_arbiter_priority_check();
    extern task do_data_compare();
    extern function int get_slave_id_with_prio();
	
	// TLM implementation define methods
	extern virtual task put_chnl0(mon_data_t t);
	extern virtual task put_chnl1(mon_data_t t);
	extern virtual task put_chnl2(mon_data_t t);
	extern virtual task put_fmt(fmt_trans t);
	extern virtual task put_reg(reg_trans t);
	
	extern virtual task peek_chnl0(output mon_data_t t);
	extern virtual task peek_chnl1(output mon_data_t t);
	extern virtual task peek_chnl2(output mon_data_t t);
	extern virtual task get_chnl0(output mon_data_t t);
	extern virtual task get_chnl1(output mon_data_t t);
	extern virtual task get_chnl2(output mon_data_t t);
	
	extern virtual task get_reg(output reg_trans t);
endclass


//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////
//Constructor
function void mcdf_scb::new(string name = "mcdf_scb", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void mcdf_scb::build_phase(uvm_phase phase);
	super.build_phase(phase);
	err_cnt		= 0;
	total_cnt	= 0;
	foreach(chnl_cnt[i]) chnl_cnt[i] = 0;
	refmod	= mcdf_refmod::type_id::create("refmod", this)
	
	chnl0_bp_imp 	= new("chnl0_bp_imp", this);
	chnl1_bp_imp 	= new("chnl1_bp_imp", this);
	chnl2_bp_imp 	= new("chnl2_bp_imp", this);
	fmt_bp_imp		= new("fmt_bp_imp"	, this);
	reg_bp_imp		= new("reg_bp_imp"	, this);
    
	reg_bg_imp		= new("reg_bg_imp"	, this); 
	
	chnl0_bgpk_imp	= new("chnl0_bgpk_imp", this);
	chnl1_bgpk_imp  = new("chnl1_bgpk_imp", this);
    chnl2_bgpk_imp  = new("chnl2_bgpk_imp", this);
	
	foreach(exp_bg_port[i]) exp_bg_port[i] = new($sformatf("exp_bg_port[%0d]", i), this);
    
	//create mailbox
	fmt_mb = new();
	reg_mb = new();
	foreach(chnl_mbs[i]) chnl_mbs[i] = new();
	
endfunction

//connect_phase
function void mcdf_scb::connect_phase(uvm_ phase);
	super.connect_phase(phase);
	refmod.reg_bg_port.connect(reg_bg_imp);
	refmod.in_bgpk_ports[0].connect(chnl0_bgpk_imp);
	refmod.in_bgpk_ports[1].connect(chnl1_bgpk_imp);
	refmod.in_bgpk_ports[2].connect(chnl2_bgpk_imp);

	foreach(exp_bg_port[i]) exp_bg_port.connect(refmod.out_tlm_fifos[i].blocking_get_export);
endfunction
                         
//run_phase
task mcdf_scb::run_phase(uvm_phase phase);
    fork
		do_channel_disable_check(0);
		do_channel_disable_check(1);
		do_channel_disable_check(2);
		do_arbiter_priority_check();
		do_data_compare();
		//what is this run for?
		refmod.run();
    join
endtask

task mcdf_scb::report_phase(uvm_phase phase);
	string s;
	super.report_phase(phase);
	s = "\n--------------------------------------------------\n"
	s = {s, "MCDF SCOREBOARD SUMMARY \n"};
	s = {s, $sformatf("total comparison count: %0d \n", total_cnt)};
	foreach(chnl_cnt[i]) s = {s, $sformatf("chnl[%0d] comparison count: %0d \n", i, chnl_cnt[i])};
	s = {s, $sformatf("total error count: %0d \n", err_cnt};
	
	foreach(chnl_mbs[i])begin
		if(chnl_mbs[i].num() != 0)
			s = {s, $sformatf("WARNING::chnl_mbs[%0d] is not empty! size is %0d \n", i, chnl_mbs[i].num())};
	
	foreach(fmt_mb[i])begin
		if(fmt_mb[i].num() != 0)
			s = {s, $sformatf("WARNING::fmt_mb[%0d] is not empty! size is %0d \n", i, fmt_mb[i].num())};	
	end
	s = {s, "\n--------------------------------------------------\n"}
	`uvm_info(get_type_name(), s, UVM_LOW)
endtask

// User Defined Methods:
function void mcdf_scb::set_interface(	virtual mcdf_intf 	mcdf_vif,
										virtual chnl_intf 	chnl_vifs,
										virtual arb_intf	arb_vif,
									);
    //set refmode interface
	if(mcdf_vif == null)
        `uvm_fatal(get_type_name(), "Error in getting mcdf_vif")
    else begin 
        this.mcdf_vif = mcdf_vif; 
		this.refmod.set_interface(mcdf_vif);
	end
	
	if(chnl_vifs == null)
        `uvm_fatal(get_type_name(), "Error in getting chnl_vifs")
    else
        this.chnl_vifs = chnl_vifs; 
		
	if(arb_vif == null)
        `uvm_fatal(get_type_name(), "Error in getting arb_vif")
    else
        this.arb_vif = arb_vif;

endfunction

task mcdf_scb::do_channel_disable_check(int id);
	forever begin
		@(posedge this.mcdf_vif.clk iff (this.mcdf_vif.rstn && this.mcdf_vif.mon_cb.chnl_en[id]));
		if(this.chnl_vifs[id].mon_cb.ch_ready === 1)
			`uvm_error(get_type_name(), "Error! when channel is disabled, ready signal is raised high")
	end
endtask

task mcdf_scb::do_arbiter_priority_check();
	int id;
	@(posedge this.arb_vif.clk iff (this.arb_vif.rstn && this.arb_vif.mon_cb.f2a_id_req === 1));
	id = get_slave_id_with_prio();
	if(id >= 0)begin
		@(posedge this.arb_if.clk);
		if(this.arb_vif.mon_cb.a2s_acks[id] !== 1)
			`uvm_error(get_type_name(), $sformatf("Error! arbiter receive req from formatter, requeset for channel[%0d] is not granted by arbiter", id))
	end
endtask

task mcdf_scb::do_data_compare();
	fmt_trans	mon_fmt_trans, ref_fmt_trans;
	bit			cmp;
	forever begin
		fmt_mb.get(mon_fmt_trans);
		exp_bg_port[mon_fmt_trans.ch_id].get(ref_fmt_trans);
		cmp = mon_fmt_trans.compare(ref_fmt_trans);
		total_cnt++;
		chnl_cnt[mon_fmt_trans.ch_id]++;
		if(cmp == 0)begin
			this.err_cnt++;
			`uvm_error("scoreboard", $sformatf("total count %0d data compare failed", total_cnt))
		end else
			`uvm_info("[CMPSUC]",$sformatf("total count %0d data compare passed", this.total_count), UVM_LOW)
	end
endtask

function int get_slave_id_with_prio();
	int id = 1;
	int prio = 99;
	foreach(this.arb_vif.mon_cb.slv_prios[i]) begin
		if(this.arb_vif.mon_cb.slv_prios[i] < prio && this.mon_cb.slv_reqs[i])begin
			id = i;
			prio = this.arb_vif.mon_cb.slv_prios[i];
		end
		return id;
	end
endfunction	
// TLM implementation define methods
task mcdf_scb:: put_chnl0(mon_data_t t);
	chnl_mbs[0].put(t);
endtask

task mcdf_scb:: put_chnl1(mon_data_t t);
	chnl_mbs[1].put(t);
endtask

task mcdf_scb:: put_chnl2(mon_data_t t);
	chnl_mbs[2].put(t);
endtask

task mcdf_scb:: put_fmt(fmt_trans t);
	fmt_mb.put(t);
endtask

task mcdf_scb:: put_reg(reg_trans t);
	reg_mb.put(t);
endtask
    
task mcdf_scb:: peek_chnl0(output mon_data_t t);
	chnl_mbs[0].peek(t);
endtask

task mcdf_scb:: peek_chnl1(output mon_data_t t);
	chnl_mbs[2].peek(t);
endtask

task mcdf_scb:: peek_chnl2(output mon_data_t t);
	chnl_mbs[2].peek(t);
endtask

task mcdf_scb:: get_chnl0(output mon_data_t t);
	chnl_mbs[0].get(t);
endtask

task mcdf_scb:: get_chnl1(output mon_data_t t);
	chnl_mbs[1].get(t);
endtask

task mcdf_scb:: get_chnl2(output mon_data_t t);
	chnl_mbs[2].get(t);
endtask

task mcdf_scb:: get_reg(output reg_trans t);
	reg_mb.get(t);
endtask







`endif