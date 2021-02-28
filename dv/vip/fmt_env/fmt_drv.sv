//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/26/2021 Fri 20:21
// Filename: 		fmt_drv.sv
// class Name: 		fmt_drv
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> channel driver, to drive data and valid signals to interface
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_FMT_DRV_SV
`define MCDF_FMT_DRV_SV

class fmt_drv extends uvm_driver;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
    virtual fmt_intf vif;
    
    local mailbox #(bit[31:0]) fifo;
    local int   fifo_bound;
    local int   data_consum_period;
		
	//Factory Registration
	//
    `uvm_component_utils(fmt_drv)
 
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "fmt_drv", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	// User Defined Methods:
    extern virtual function void set_interface(virtual chnl_intf vif);
    extern task do_receive    ();
    extern task do_consume    ();
    extern task do_config     ();
    extern task do_reset      ();
	
endclass

//Constructor
function void fmt_drv::new(string name = "fmt_drv", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void fmt_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);
    this.fifo = new();
    this.fifo_bound = 4096;
    this.data_consum_period = 1;
endfunction

//Run_Phase
task fmt_drv::run_phase(uvm_phase phase);
    fork
        this.do_receive    ();
        this.do_consume    ();
        this.do_config     ();
        this.do_reset      ();
    join
endtask

// User Defined Methods:
function void fmt_drv::set_interface(virtual fmt_intf vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "Error in getting Interface")
    else 
        this.vif = vif; 
endfunction

task fmt_drv::do_receive();
    forever begin
        @(posedge vif.fmt_req);
        forever begin
            @(posedge vif.clk);
            if((this.fifo_bound-this.fifo.num()) >= vif.fmt_length)
                break;
        end
        vif.drv_cb.fmt_grant <= 1;
        @(posedge vif.fmt_start);
        fork
            begin
                @(posedge vif.clk);
                vif.drv_cb.fmt_grant <= 0;
            end
        join_none
        
        repeat(vif.fmt_length) begin
            @(negedge vif.clk);
            this.fifo.put(vif.fmt_data);       
        end
    end
endtask

task fmt_drv::do_consume();
    bit [31:0] data;
    forever begin
        void'(this.try_get(data));
        repeat($urandom_range(1, this.data_consum_period))
            @(posedge vif.clk);
    end
endtask

task fmt_drv::do_config();
    fmt_trans req, rsp;
    forever begin
        seq_item_port.get_next_item(req);
        case(req.fmt_fifo)
            SHORT_FIFO  : this.fifo_bound = 64;
            MED_FIFO    : this.fifo_bound = 256;
            LONG_FIFO   : this.fifo_bound = 512;
            ULTRA_FIFO  : this.fifo_bound = 2048;
        endcase
        this.fifo = new(this.fifo_bound);
        
        case(req.fmt_bandwidth)
            LOW_WIDTH   : this.data_consum_period = 8;
            MED_WIDTH   : this.data_consum_period = 4;
            HIGH_WIDTH  : this.data_consum_period = 2;
            ULTRA_WIDTH : this.data_consum_period = 1;        
        endcase
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
    end
endtask

task fmt_drv::do_reset();
    forever begin
        @(negedge vif.rstn);
        vif.drv_cb.fmt_grant <= 0;
    end
endtask


`endif