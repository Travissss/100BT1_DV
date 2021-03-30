//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/02/2021 Tue 21:19 
// Filename: 		reg_drv.sv
// class Name: 		reg_drv
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> register driver, to drive data and valid signals to interface
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_REG_DRV_SV
`define MCDF_REG_DRV_SV

class reg_drv extends uvm_driver #(reg_trans);

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual reg_intf vif;
		
	//Factory Registration
	//
    `uvm_component_utils(reg_drv)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "reg_drv", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual reg_intf vif);
    extern task do_reset    ();
    extern task do_drive    ();
    extern task reg_write   (input reg_trans pkt);
    extern task reg_idle    ();
	
endclass

//Constructor
function reg_drv::new(string name = "reg_drv", uvm_component parent);
	super.new(name, parent);
endfunction

//Build_Phase
function void reg_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run_Phase
task reg_drv::run_phase(uvm_phase phase);
    `uvm_info("reg_drv::", $sformatf("run_phase debug:get into run_phase fork join "), UVM_HIGH)
    fork
        this.do_reset();
        this.do_drive();
    join
    `uvm_info("reg_drv::", $sformatf("run_phase debug:get out from run_phase fork join "), UVM_HIGH)
endtask

// User Defined Methods:
function void reg_drv::set_interface(virtual reg_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task reg_drv::do_reset();
    forever begin
        @(negedge vif.rstn);
        vif.cmd             <= `IDLE;
        vif.cmd_addr        <= 8'b0;
        vif.cmd_data_m2s    <= 32'b0;
		vif.loc_low_timer	<= 32'b0;
		vif.loc_high_timer	<= 32'b0;
    end
    `uvm_info("reg_drv::", $sformatf("run_phase debug:get out from run_phase do_reset() "), UVM_HIGH)
endtask

task reg_drv::do_drive();
    reg_trans req, rsp;
    @(posedge vif.rstn);
    forever begin
        seq_item_port.get_next_item(req);
        this.reg_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
    end
    `uvm_info("reg_drv::", $sformatf("run_phase debug:get out from run_phase do_drive() "), UVM_HIGH)
endtask

task reg_drv::reg_write(reg_trans pkt);
    @(posedge vif.clk iff vif.rstn);
    case(pkt.cmd)
        `WRITE:begin
            vif.drv_cb.cmd             	<= pkt.cmd ;       
            vif.drv_cb.cmd_addr        	<= pkt.addr;
            vif.drv_cb.cmd_data_m2s    	<= pkt.data;
			vif.drv_cb.loc_low_timer	<= pkt.loc_low_timer;
			vif.drv_cb.loc_high_timer	<= pkt.loc_high_timer;
        end
        
        `READ: begin
            vif.drv_cb.cmd         	 <= pkt.cmd;       
            vif.drv_cb.cmd_addr    	 <= pkt.addr;
			vif.drv_cb.loc_low_timer <= pkt.loc_low_timer;
			vif.drv_cb.loc_high_timer<= pkt.loc_high_timer;
            repeat(2) @(negedge vif.clk);
            pkt.data        = vif.cmd_data_s2m;     
        end
        
        `IDLE: begin
			this.reg_idle();
			vif.drv_cb.loc_low_timer	<= pkt.loc_low_timer;
			vif.drv_cb.loc_high_timer	<= pkt.loc_high_timer;
		end
	
	endcase
    `uvm_info("reg_drv::", $sformatf("run_phase debug:get out from run_phase reg_write() "), UVM_HIGH)
endtask

task reg_drv::reg_idle();
    @(posedge vif.clk);
        vif.drv_cb.cmd             	<= `IDLE;
        vif.drv_cb.cmd_addr        	<= 8'b0;
        vif.drv_cb.cmd_data_m2s    	<= 32'b0;
endtask

`endif
