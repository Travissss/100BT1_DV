//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/02/2021 Tue 21:30 
// Filename: 		reg_mon.sv
// class Name: 		reg_mon
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> register monitor
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_REG_MON_SV
`define MCDF_REG_MON_SV

class reg_mon extends uvm_monitor;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual reg_intf vif;
	uvm_blocking_put_port 	#(reg_trans) mon_bp_port;
    uvm_analysis_port 		#(reg_trans) mon_ap;
	//Factory Registration
	//
    `uvm_component_utils(reg_mon)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "reg_mon", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual fmt_intf vif);
    extern task mon_trans();

endclass

//Constructor
function void reg_mon::new(string name = "reg_mon", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void reg_mon::build_phase(uvm_phase phase);
	super.build_phase(phase);
    mon_bp_port = new("mon_bp_port", this);
    mon_ap      = new("mon_ap", this);
endfunction

//Run_Phase
task reg_mon::run_phase(uvm_phase phase);
    
    this.mon_trans();
    
endtask

// User Defined Methods:
function void reg_mon::set_interface(virtual fmt_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task reg_mon::mon_trans();
    reg_trans pkt;
    string s;
    forever begin
        @(posedge vif.clk iff(vif.rstn && vif.mon_cb.cmd != `IDLE));
        pkt = new();
        pkt.cmd     = vif.mon_cb.cmd;
        pkt.addr    = vif.mon_cb.cmd_addr;
        if(cmd == `WRITE)
            pkt.data = vif.mon_cb.cmd_data_m2s;
        else if (cmd == `READ) begin
            @(posedge vif.clk);
            pkt.data = vif.mon_cb.cmd_data_s2m;
        end
        mon_bp_port.put(pkt);
        mon_ap.write(pkt);

        `uvm_info(get_type_name(), $sformatf("monitored addr %2x, cmd %2b, data %8x", pkt.cmd, pkt.addr, pkt.data), UVM_MEDIUM)
    end
endtask

`endif