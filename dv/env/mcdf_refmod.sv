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

class mcdf_refmod extends uvm_component;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual mcdf_intf   vif;
	mcdf_reg_t          regs[3];
    
    uvm_blocking_get_port 		#(reg_trans) 	reg_bg_port;
    uvm_blocking_get_peek_port 	#(mon_data_t)	in_bgpk_ports[3];
    
    //from formatter monitor analysis_port mon_ap
    uvm_tlm_analysis_fifo 		#(fmt_trans)	out_tlm_fifos[3];
    
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
    extern virtual function void set_interface(virtual mcdf_intf vif);
    extern task do_reset();
    extern task do_reg_update();
    extern task do_packet(int id);
    extern task get_field_value(int id, mcdt_field_t f);
endclass

//Constructor
function void mcdf_refmod::new(string name = "mcdf_refmod", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void mcdf_refmod::build_phase(uvm_phase phase);
	super.build_phase(phase);
    reg_bg_port = new("reg_bg_port", this);
    foreach(in_bgpk_ports[i]) in_bgpk_ports[i] = new($sformatf("in_bgpk_ports[%0d]", i), this);
    foreach(out_tlm_fifos[i]) out_tlm_fifos[i] = new($sformatf("out_tlm_fifos[%0d]", i), this);
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
function void mcdf_refmod::set_interface(virtual mcdf_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
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
	mon_data_t	mon_tr;
	forever begin
		this.in_bgpk_ports[id].peek(mon_tr);
		//fmt_tr = new();
		fmt_tr = new("fmt_tr");
		fmt_tr.length 	= 4 << (this.get_field_value(id, RW_LEN) & 'b11);
		fmt_tr.data		= new[fmt_tr.length];
		fmt_tr.ch_id	= id;
		foreach(fmt_tr.data[i])begin
			this.in_bgpk_ports[id].get(mon_tr);
			fmt_tr.data[i] = mon_tr.data
		end
		this.out_tlm_fifos[id].put(fmt_tr);
	end
endtask

task get_field_value(int id, mcdf_field_t s);
	case(s)
		RW_LEN	: return regs[id].len;
		RW_PRIO	: return regs[id].prio;
		RW_EN	: return regs[id].en;
		RD_AVAIL: return regs[id].avail;
endtask
`endif