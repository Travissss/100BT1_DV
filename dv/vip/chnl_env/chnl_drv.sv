//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/17/2021 Wed 20:03
// Filename: 		chnl_drv.sv
// class Name: 		chnl_drv
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel driver, to drive data and valid signals to interface
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CHNL_DRV_SV
`define MCDF_CHNL_DRV_SV

class chnl_drv extends uvm_driver#(chnl_trans);

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual chnl_intf vif;
		
	//Factory Registration
	//
    `uvm_component_utils(chnl_drv)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "chnl_drv", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual chnl_intf vif);
    extern task do_reset    (virtual chnl_intf vif);
    extern task do_drive    ();
    extern task chnl_write  (input chnl_trans pkt);
    extern task chnl_idle   ();
	
endclass

//Constructor
function void chnl_drv::new(string name = "chnl_drv", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void chnl_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run_Phase
task chnl_drv::run_phase(uvm_phase phase);
    fork
        this.do_reset();
        this.do_drive();
    join
endtask

// User Defined Methods:
function void chnl_drv::set_interface(virtual chnl_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task chnl_drv::do_reset();
    forever begin
        @(negedge vif.rstn);
        vif.ch_valid    <= 0;
        vif.ch_data     <= 0;
    end
endtask

task chnl_drv::do_drive();
    chnl_trans req, rsp;
    @(posedge vif.rstn);
    forever begin
        seq_item_port.get_next_item(req);
        this.chnl_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
    end
endtask

task chnl_drv::chnl_write(input chnl_trans pkt);
    foreach(pkt.data[i]) begin
        @(posedge vif.clk);
        vif.drv_cb.ch_valid <= 1;
        vif.drv_cb.ch_data <= pkt.data[i];
        @(negedge vif.clk);
        wait(vif.ch_ready === 1'b1);
        `uvm_info(get_type_name(), $sformatf("sent data 'h%8x", pkt.data[i]), UVM_HIGH)
        repeat(pkt.data_nidles) chnl_idle();
    end
    repeat(pkt.pkt_nidles) chnl_idle();
endtask

task chnl_drv::chnl_idle();
    @(posedge vif.clk);
    vif.drv_cb.ch_valid <= 0;
    vif.drv_cb.ch_data <= 0; 
endtask

`endif