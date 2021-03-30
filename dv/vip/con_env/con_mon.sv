//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/28/2021 Sun 13:41
// Filename: 		con_mon.sv
// class Name: 		con_mon
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> converter monitor
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CON_MON_SV
`define MCDF_CON_MON_SV

class con_mon extends uvm_monitor;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    string name;
	virtual con_intf vif;
	uvm_analysis_port #(con_trans) mon_ap;
	//Factory Registration
	//
    `uvm_component_utils(con_mon)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "con_mon", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual con_intf vif);
    extern task mon_trans();

endclass

//Constructor
function con_mon::new(string name = "con_mon", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void con_mon::build_phase(uvm_phase phase);
	super.build_phase(phase);
    mon_ap = new("mon_ap", this);
endfunction

//Run_Phase
task con_mon::run_phase(uvm_phase phase);
    
    this.mon_trans();
    
endtask

// User Defined Methods:
function void con_mon::set_interface(virtual con_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task con_mon::mon_trans();
    con_trans pkt;
	string s;
    forever begin
        @(posedge vif.clk_33m iff (vif.rstn && vif.mon_cb.tx_enable==='b1));
		pkt = new();
		pkt.seed    		= vif.mon_cb.seed;
		pkt.tx_mode			= vif.mon_cb.tx_mode;
		pkt.master_slave 	= vif.mon_cb.master_slave;
		pkt.rcv_vld 		= vif.mon_cb.rcv_vld;
		pkt.TAn 			= vif.mon_cb.TAn;
		pkt.TBn				= vif.mon_cb.TBn;		
		mon_ap.write(pkt);
		s = $sformatf("================================================\n");
        s = {s, $sformatf("%0t %s monitor a packet: \n", $time, this.name)};
        s = {s, $sformatf("tx_mode = %0x: \n", pkt.tx_mode)};
        s = {s, $sformatf("master_slave = %0x: \n", pkt.master_slave)};
        s = $sformatf("================================================\n");
        `uvm_info(get_type_name(), s, UVM_MEDIUM)
    end
endtask

`endif