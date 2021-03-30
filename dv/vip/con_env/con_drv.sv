//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/28/2021 Sun 13:11
// Filename: 		con_drv.sv
// class Name: 		con_drv
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> converter driver, to drive tx_mode, interface, seed, rcv_vld to interface
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CON_DRV_SV
`define MCDF_CON_DRV_SV

class con_drv extends uvm_driver#(con_trans);

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual con_intf vif;
		
	//Factory Registration
	//
    `uvm_component_utils(con_drv)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "con_drv", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual con_intf vif);
    extern task do_reset    ();
    extern task do_drive    ();
    extern task con_write  (input con_trans pkt);
	
endclass

//Constructor
function con_drv::new(string name = "con_drv", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void con_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run_Phase
task con_drv::run_phase(uvm_phase phase);
    fork
        this.do_reset();
        this.do_drive();
    join
endtask

// User Defined Methods:
function void con_drv::set_interface(virtual con_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task con_drv::do_reset();
    forever begin
        @(negedge vif.rstn);
        vif.drv_cb.seed    		<= 0;
        vif.drv_cb.tx_mode		<= 0;
		vif.drv_cb.master_slave <= 0;
		vif.drv_cb.rcv_vld 		<= 0;
    end
	`uvm_info("con_drv::", $sformatf("run_phase debug:get out from run_phase do_reset() "), UVM_HIGH)
endtask

task con_drv::do_drive();
    con_trans req, rsp;
    @(posedge vif.rstn);
    forever begin
        seq_item_port.get_next_item(req);
        this.con_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
    end
	`uvm_info("con_drv::", $sformatf("run_phase debug:get out from run_phase do_drive() "), UVM_HIGH)
endtask

task con_drv::con_write(input con_trans pkt);
	@(posedge vif.clk_33m iff vif.tx_enable);
	if(pkt.master_slave) begin
	    vif.drv_cb.seed    		<= pkt.seed;
        vif.drv_cb.tx_mode		<= pkt.tx_mode;
		vif.drv_cb.master_slave	<= 1;
		repeat(pkt.wait_vld) @(posedge vif.clk_33m);
		vif.drv_cb.rcv_vld 		<= 1;
	end
	else begin
	    vif.drv_cb.seed    		<= pkt.seed;
        vif.drv_cb.tx_mode		<= pkt.tx_mode;
		vif.drv_cb.master_slave <= 0;
		vif.drv_cb.rcv_vld 		<= 1;
	end
	`uvm_info("con_drv::", $sformatf("run_phase debug:get out from run_phase con_write() "), UVM_HIGH)
endtask


`endif
