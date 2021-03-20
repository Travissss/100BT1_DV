//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/23/2021 Thu 20:19
// Filename: 		chnl_mon.sv
// class Name: 		chnl_mon
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel monitor
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CHNL_MON_SV
`define MCDF_CHNL_MON_SV

class chnl_mon extends uvm_monitor;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual chnl_intf vif;
	uvm_blocking_put_port #(mon_data_t) mon_bp_port;
	//Factory Registration
	//
    `uvm_component_utils(chnl_mon)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "chnl_mon", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual chnl_intf vif);
    extern task mon_trans();

endclass

//Constructor
function void chnl_mon::new(string name = "chnl_mon", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void chnl_mon::build_phase(uvm_phase phase);
	super.build_phase(phase);
    mon_bp_port = new("mon_bp_port", this);
endfunction

//Run_Phase
task chnl_mon::run_phase(uvm_phase phase);
    
    this.mon_trans();
    
endtask

// User Defined Methods:
function void chnl_mon::set_interface(virtual chnl_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task chnl_mon::mon_trans();
    mon_data_t pkt;
    forever begin
        @(posedge vif.clk iff (vif.mon_cb.ch_valid==='b1 && vif.mon_cb.ch_ready==='b1));
        pkt.data = vif.mon_cb.ch_data;
        mon_bp_port.put(pkt);
        `uvm_info(get_type_name(), $sformatf("monitored channel data 'h%8x", m.data), UVM_HIGH)
    end
endtask

`endif