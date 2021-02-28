//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/28/2021 SUN 17:27
// Filename: 		fmt_mon.sv
// class Name: 		fmt_mon
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel monitor
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_FMT_MON_SV
`define MCDF_FMT_MON_SV

class fmt_mon extends uvm_monitor;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    string  name;
    virtual fmt_intf vif;
	uvm_blocking_put_port #(fmt_trans) mon_bp_port;
	//Factory Registration
	//
    `uvm_component_utils(fmt_mon)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "fmt_mon", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual fmt_intf vif);
    extern task mon_trans();

endclass

//Constructor
function void fmt_mon::new(string name = "fmt_mon", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void fmt_mon::build_phase(uvm_phase phase);
	super.build_phase(phase);
    mon_bp_port = new("mon_bp_port", this);
endfunction

//Run_Phase
task fmt_mon::run_phase(uvm_phase phase);
    
    this.mon_trans();
    
endtask

// User Defined Methods:
function void fmt_mon::set_interface(virtual fmt_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task fmt_mon::mon_trans();
    fmt_trans pkt;
    string s;
    forever begin
        @(posedge vif.mon_cb.fmt_start);
            pkt = new();
            pkt.length  = vif.mon_cb.fmt_length;
            pkt.ch_id   = vif.mon_cb.fmt_chid;
            pkt.data    = vif.mon_cb.fmt_data;
            foreach(pkt.data[i]) begin
                @(posedge vif.clk);
                pkt.data[i] = vif.mon_cb.fmt_data;
            end
        mon_bp_port.put(pkt);
        s = $sformatf("================================================\n");
        s = {s, $sformatf("%0t %s monitor a packet: \n", $time, this.name);
        s = {s, $sformatf("length = %0x: \n", pkt.length)};
        s = {s, $sformatf("chid = %0x: \n", pkt.ch_id)};
        foreach(pkt.data[i]) s = {s, $sformatf("data[%0d] = %8x \n",i , pkt.data[i])};
        s = $sformatf("================================================\n");
        `uvm_info(get_type_name(), s, UVM_MEDIUM)
    end
endtask

`endif