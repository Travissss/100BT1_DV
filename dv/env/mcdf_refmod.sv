//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/04/2021 Tue 21:35 
// Filename: 		mcdf_refmod.sv
// class Name: 		mcdf_refmod
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> mcdf reference model
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_REFMOD_SV
`define MCDF_REFMOD_SV
import  "DPI-C" converter_3b_pam=function void converter_3b_pam(
    //input bit [2:0] scr_data	,
    input  scr_data0	,
    input  scr_data1	,
    input  scr_data2	,

	input bit [1:0] tx_mode		,
	input bit [31:0]loop_num,
	input bit 		master_slave,
	output bit [1:0]TAn			,
	output bit [1:0]TBn			
	);
	
class mcdf_refmod extends uvm_component;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	bit [3:0]	mii_data[];
	bit [2:0]	scr_data[];
	bit [1:0]	tx_mode;
    virtual mcdf_intf   vif;
	virtual con_intf	con_vif;
	mcdf_reg_t          regs[3];
    
    uvm_blocking_get_port 		#(reg_trans) 	reg_bg_port;
    uvm_blocking_get_peek_port 	#(mon_data_t)	in_bgpk_ports[3];
    
    //from formatter monitor analysis_port mon_ap
    uvm_tlm_analysis_fifo 		#(fmt_trans)	out_tlm_fifos[3];
    uvm_tlm_analysis_fifo 		#(con_trans)	con_tlm_fifo;
	
	//Factory Registration
	//
    `uvm_component_utils(mcdf_refmod)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_refmod", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual mcdf_intf vif, virtual con_intf con_vif);
    extern task do_reset();
    extern task do_reg_update();
    extern task do_packet(int id);
    extern function int get_field_value(int id, mcdf_field_t s);
endclass

//Constructor
function mcdf_refmod::new(string name = "mcdf_refmod", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void mcdf_refmod::build_phase(uvm_phase phase);
	super.build_phase(phase);
    reg_bg_port = new("reg_bg_port", this);
    foreach(in_bgpk_ports[i]) in_bgpk_ports[i] = new($sformatf("in_bgpk_ports[%0d]", i), this);
    foreach(out_tlm_fifos[i]) out_tlm_fifos[i] = new($sformatf("out_tlm_fifos[%0d]", i), this);
	con_tlm_fifo = new("con_tlm_fifo", this);
endfunction

//Run_Phase
task mcdf_refmod::run_phase(uvm_phase phase);
    fork
        do_reset();
        do_reg_update();
        do_packet(0);
        do_packet(1);
        do_packet(2);
    join
endtask

// User Defined Methods:
function void mcdf_refmod::set_interface(virtual mcdf_intf vif, virtual con_intf con_vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else begin
        this.vif 	 = vif; 
		this.con_vif = con_vif;
	end
endfunction

task mcdf_refmod::do_reset();
    forever begin
        @(negedge vif.rstn);
        foreach(regs[i]) begin
            regs[i].len     = 'h0;
            regs[i].prio    = 'h3;
            regs[i].en      = 'h1;
            regs[i].avail   = 'h20;
        end
    end
endtask

//update register value
task mcdf_refmod::do_reg_update();
    reg_trans tr;
    forever begin
        this.reg_bg_port.get(tr);
		// loc_low_timer	= tr.loc_low_timer;
		// loc_high_timer	= tr.loc_high_timer;
        if(tr.addr[7:4] == 0 && tr.cmd == `WRITE) begin
				this.regs[tr.addr[3:2]].en	= tr.data[0];
				this.regs[tr.addr[3:2]].prio= tr.data[2:1];
				this.regs[tr.addr[3:2]].len	= tr.data[5:3];
		end
		else if(tr.addr[7:4] == 1 && tr.cmd == `READ)begin
			this.regs[tr.addr[3:2]].avail 	= tr.data[7:0];
		end
    end
endtask

task mcdf_refmod::do_packet(int id);
	fmt_trans	fmt_tr;
	con_trans	con_tr_ref;
	mon_data_t	mon_tr;
	int master_slave = 0;
	bit	[31:0]	mii_len;
	bit [31:0]	scr_len;
	bit [31:0]	real_scr_len;
	bit [1:0] TAn = 1;
	bit [1:0] TBn = 3;
	
	int			loop_i;
	forever begin
		tx_mode = con_vif.tx_mode;
		this.in_bgpk_ports[id].peek(mon_tr);
		//fmt_tr = new();
		fmt_tr = new("fmt_tr");
		con_tr_ref = new("con_tr_ref");
		fmt_tr.length 	= 4 << (this.get_field_value(id, RW_LEN) & 'b11);
		mii_len  		= (fmt_tr.length << 1 + (1 << (this.get_field_value(id, RW_LEN) & 'b11)));
		scr_len  		= 12 << (this.get_field_value(id, RW_LEN) & 'b11);
		if(scr_len == 12)		real_scr_len = 11;	
		else if (scr_len == 24)	real_scr_len = 22;	
		else if (scr_len == 48)	real_scr_len = 43;
		else if (scr_len == 96)	real_scr_len = 86;
		loop_i			= 3 << (this.get_field_value(id, RW_LEN) & 'b11);
		fmt_tr.data		= new[fmt_tr.length];
		fmt_tr.ch_id	= id;
		mii_data		= new[mii_len];
		scr_data		= new[scr_len];
		foreach(mii_data[i]) mii_data[i] = 0;
		//gmii to mii
		foreach(fmt_tr.data[i])begin
			int j;
			j = i << 1;
			this.in_bgpk_ports[id].get(mon_tr);
			fmt_tr.data[i] 	= mon_tr.data;
			mii_data[j]		= mon_tr.data[3:0];
			mii_data[j+1]		= mon_tr.data[7:4];
			`uvm_info("[REFERENCE MODEL ]",$sformatf("mii_data[%0d] = %0x", j, mii_data[j]), UVM_LOW)
			`uvm_info("[REFERENCE MODEL ]",$sformatf("mii_data[%0d] = %0x", j+1, mii_data[j+1]), UVM_LOW)
		end
		//4B to 3B
		for (int x = 0; x < loop_i; x++) begin
			int k, j;
			j = x + (x<<1);
			k = x << 2;
			if(x == 0)begin
			scr_data[k] 	= mii_data[0][2:0];
			scr_data[k+1]	= {mii_data[1][1:0],mii_data[0][3]};
			scr_data[k+2]	= {mii_data[2][0], mii_data[1][3:2]};	
			scr_data[k+3]	= mii_data[2][3:1];
			end else begin
				scr_data[k] 	= mii_data[j][2:0];
				scr_data[k+1]	= {mii_data[j+1][1:0],mii_data[j][3]};
				scr_data[k+2]	= {mii_data[j+2][0], mii_data[j+1][3:2]};	
				scr_data[k+3]	= mii_data[j+2][3:1];
			end
		end
		
		for (int j = 0; j < real_scr_len; j++) begin
			bit [31:0] loop_num = j;
			bit [2:0] tmp;
			int scr_data0, scr_data1, scr_data2;
			tmp = scr_data[j];
			scr_data0 = (tmp[0] == 1) ? 1 : 0;
			scr_data1 = (tmp[1] == 1) ? 1 : 0;
			scr_data2 = (tmp[2] == 1) ? 1 : 0;
			converter_3b_pam(scr_data0,scr_data1, scr_data2, tx_mode, loop_num, master_slave, TAn, TBn);
			`uvm_info("[REFERENCE MODEL ]",$sformatf("scr_data[%0d] = %0x, scr_data0, 1, 2 = %0x, %0x, %0x", j, scr_data[j], scr_data0, scr_data1, scr_data2), UVM_LOW)
			`uvm_info("[REFERENCE MODEL ]",$sformatf("tx_mode = %0x", tx_mode), UVM_LOW)
			`uvm_info("[REFERENCE MODEL ]",$sformatf("loop_num = %0x", loop_num), UVM_LOW)
			`uvm_info("[REFERENCE MODEL ]",$sformatf("master_slave = %0x", master_slave), UVM_LOW)
			`uvm_info("[REFERENCE MODEL ]",$sformatf("TAn = %0x, TBn = %0x", TAn, TBn), UVM_LOW)
			con_tr_ref.TAn = TAn;
			con_tr_ref.TBn = TBn;
			con_tlm_fifo.put(con_tr_ref);
		end
		
		this.out_tlm_fifos[id].put(fmt_tr);
	end
endtask



function int mcdf_refmod::get_field_value(int id, mcdf_field_t s);
	case(s)
		RW_LEN	: return regs[id].len;
		RW_PRIO	: return regs[id].prio;
		RW_EN	: return regs[id].en;
		RD_AVAIL: return regs[id].avail;
	endcase
endfunction
`endif
