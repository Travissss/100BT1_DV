//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/07/2021 Sun 17:20
// Filename: 		mcdf_cov.sv
// class Name: 		mcdf_cov
// Project Name: 	ahb2apb_bridge
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Collect coverage info
//////////////////////////////////////////////////////////////////////////////////

class mcdf_cov extends uvm_object;

	//------------------------------------------
	// Data, Interface, port  Members
	//------------------------------------------
	virtual chnl_intf	chnl_vifs[3];
	virtual arb_intf	arb_vif;
	virtual mcdf_intf	mcdf_vif;
	virtual reg_intf	reg_vif;
	virtual fmt_intf	fmt_vif;
	int					delay_req_to_grant;
	
	//Factory Registration
	//
	`uvm_component_utils(mcdf_cov)

	//----------------------------------------------
	// Covergroup
	// ---------------------------------------------
	//1:for register read and wirte test
	covergroup cg_mcdf_reg_write_read;
		addr: coverpoint reg_vif.mon_cb.cmd_addr{
			type_option.weight 	= 0;
			
			bins slv0_rw_addr	= {`SLV0_RW_ADDR};
			bins slv1_rw_addr	= {`SLV1_RW_ADDR};
			bins slv2_rw_addr	= {`SLV2_RW_ADDR};
			bins slv0_r_addr	= {`SLV0_R_ADDR	};
			bins slv1_r_addr	= {`SLV1_R_ADDR	};
			bins slv2_r_addr	= {`SLV2_R_ADDR	};
		}
		
		cmd: coverpoint reg_vif.mon_cb.cmd{
			type_option.weight = 0;
			bins write	= {`WRITE	};		
			bins read	= {`READ	};
			bins idle	= {`IDLE	};
		}
	
		cmdxaddr: cross addr, cmd{
			bins slv0_rw_addr	= binsof(addr.slv0_rw_addr	);	
			bins slv1_rw_addr	= binsof(addr.slv1_rw_addr	);	
			bins slv2_rw_addr	= binsof(addr.slv2_rw_addr	);	
			bins slv0_r_addr	= binsof(addr.slv0_r_addr	);
			bins slv1_r_addr	= binsof(addr.slv1_r_addr	);
		    bins slv2_r_addr	= binsof(addr.slv2_r_addr 	);	
			
			bins write			= binsof(cmd.write	);	
		    bins read			= binsof(cmd.read	);
		    bins idle			= binsof(cmd.idle 	);	
			
			bins write_slv0_rw_addr	= binsof(cmd.write) && binsof(addr.slv0_rw_addr	);	
			bins write_slv1_rw_addr	= binsof(cmd.write) && binsof(addr.slv1_rw_addr	);	
			bins write_slv2_rw_addr	= binsof(cmd.write) && binsof(addr.slv2_rw_addr	);	
			bins read_slv0_rw_addr	= binsof(cmd.read ) && binsof(addr.slv0_rw_addr	);	
			bins read_slv1_rw_addr	= binsof(cmd.read ) && binsof(addr.slv1_rw_addr	);	
			bins read_slv2_rw_addr	= binsof(cmd.read ) && binsof(addr.slv2_rw_addr	);	
			bins read_slv0_r_addr	= binsof(cmd.read ) && binsof(addr.slv0_r_addr	);
			bins read_slv1_r_addr	= binsof(cmd.read ) && binsof(addr.slv1_r_addr	);
		    bins read_slv2_r_addr	= binsof(cmd.read ) && binsof(addr.slv2_r_addr 	);		
		}
	
	endgroup
	
	//2: for register access illegal addr
	covergroup cg_mcdf_reg_illegal_access;
		addr: coverpoint reg_vif.mon_cb.cmd_addr{
			type_option.weight = 0;
			bins legal_rw 	= {`SLV0_RW_ADDR, `SLV1_RW_ADDR, `SLV2_RW_ADDR	};
			bins legal_r	= {`SLV0_R_ADDR, `SLV1_R_ADDR, `SLV2_R_ADDR		}; 
			bins illegal	= {[8'h20:$], 8'hC, 8'h1C};
		}
		
		cmd: coverpoint reg_vif.mon_cb.cmd{
			type_option.weight = 0;
			bins write	= {`WRITE};
			bins read	= {`READ };
		}
	
		wdata: coverpoint reg_vif.mon_cb.cmd_data_m2s {
			type_option.weight = 0;
			bins legal		= {[0:'h3F]};
			bins illegal 	= {['h40:$]};		
		}
		
		rdata: coverpoint reg_vif.mon_cb.cmd_data_s2m {
			type_option.weight = 0;
			bins legal = {[0:'hFF]};
			illegal_bins illegal = default;		
		}
		
		cmd_addr_data: cross cmd, addr, wdata, rdata{
			bins addr_legal_rw	= binsof(addr.legal_rw	);
			bins addr_legal_r	= binsof(addr.legal_r 	);
			bins addr_illegal	= binsof(addr.illegal 	);
			
			bins cmd_write		= binsof(cmd.write		);
			bins cmd_read		= binsof(cmd.read 		);
			
			bins wdata_legal	= binsof(wdata.legal	);
			bins wdata_illegal	= binsof(wdata.illegal	);
			bins rdata_legal	= binsof(rdata.legal	);
			
			bins write_illegal_addr		= binsof(cmd.write) && binsof(addr.illegal );
			bins read_illegal_addr		= binsof(cmd.read )	&& binsof(addr.illegal );
			bins write_illegal_rw_data	= binsof(cmd.write) && binsof(addr.legal_rw) && binsof(wdata.illegal);
			bins write_illegal_r_data	= binsof(cmd.read ) && binsof(addr.legal_r ) && binsof(wdata.illegal);
		}	
	endgroup
	
	//3: for channel enable, disable in the meantime channel valid is high
	covergroup cg_channel_disable;

		ch0_en: coverpoint mcdf_vif.mon_cb.chnl_en[0]{
			type_option.weight = 0;			
			bins en 	= {1'b1};
			bins dis_en	= {1'b0};
		} 
		
		ch1_en: coverpoint mcdf_vif.mon_cb.chnl_en[1]{
			type_option.weight = 0;			
			bins en 	= {1'b1};
			bins dis_en	= {1'b0};
		} 
		
		ch2_en: coverpoint mcdf_vif.mon_cb.chnl_en[2]{
			type_option.weight = 0;			
			bins en 	= {1'b1};
			bins dis_en	= {1'b0};
		} 

		ch0_vld: coverpoint chnl_vifs[0].mon_cb.ch_valid[0]{
			type_option.weight = 0;			
			bins hi = {1'b1};
			bins lo	= {1'b0};
		} 
		
		ch1_vld: coverpoint chnl_vifs[1].mon_cb.ch_valid[1]{
			type_option.weight = 0;			
			bins hi = {1'b1};
			bins lo	= {1'b0};
		} 
		
		ch2_vld: coverpoint chnl_vifs[2].mon_cb.ch_valid[2]{
			type_option.weight = 0;			
			bins hi = {1'b1};
			bins lo	= {1'b0};
		} 		
		
		enxvld: cross ch0_en, ch1_en, ch2_en, ch0_vld, ch1_vld, ch2_vld {
			bins ch0_en 	= binsof(ch0_en.en		);
			bins ch1_en 	= binsof(ch1_en.en		);
			bins ch2_en 	= binsof(ch2_en.en		);
			bins ch0_dis_en = binsof(ch0_en.dis_en	);
		    bins ch1_dis_en = binsof(ch1_en.dis_en	);
		    bins ch2_dis_en = binsof(ch2_en.dis_en	);
			bins ch0_vld_hi = binsof(ch0_vld.hi		);
			bins ch1_vld_hi = binsof(ch1_vld.hi		);
			bins ch2_vld_hi = binsof(ch2_vld.hi		);
			bins ch0_vld_lo = binsof(ch0_vld.lo		);
		    bins ch1_vld_lo = binsof(ch1_vld.lo		);
		    bins ch2_vld_lo = binsof(ch2_vld.lo		);
			
			bins ch0_en_vld		= binsof(ch0_en.en		) && binsof(ch0_vld.hi);
			bins ch1_en_vld		= binsof(ch1_en.en		) && binsof(ch1_vld.hi);
			bins ch2_en_vld		= binsof(ch2_en.en		) && binsof(ch2_vld.hi);
			bins ch0_dis_en_vld	= binsof(ch0_en.dis_en	) && binsof(ch0_vld.hi);
			bins ch1_dis_en_vld	= binsof(ch1_en.dis_en	) && binsof(ch1_vld.hi);
			bins ch2_dis_en_vld	= binsof(ch2_en.dis_en	) && binsof(ch2_vld.hi);			
		}
	endgroup
	
	//4: for slave fifo with different prority
	covergroup cg_arbiter_priority;
		ch0_prio: coverpoint arb_vif.mon_cb.slv_prios[0] {
			bins ch_prio0 = {0};
			bins ch_prio1 = {1};
			bins ch_prio2 = {2};
			bins ch_prio3 = {3};
		} 
		
		ch1_prio: coverpoint arb_vif.mon_cb.slv_prios[1]{
			bins ch_prio0 = {0};
			bins ch_prio1 = {1};
		    bins ch_prio2 = {2};
		    bins ch_prio3 = {3};
		}

		ch1_prio: coverpoint arb_vif.mon_cb.slv_prios[1]{
			bins ch_prio0 = {0};
			bins ch_prio1 = {1};
		    bins ch_prio2 = {2};
		    bins ch_prio3 = {3};
		}
	endgroup
	
	//5: for formatter length
	covergroup cg_formatter_length;
		id: coverpoint fmt_vif.mon_cb.fmt_chid{
			bins ch0 = {0};
			bins ch1 = {1};
			bins ch2 = {2};
			illegal_bins illegel = default;	
		}
		
		length: coverpoint fmt_vif.mon_cb.fmt_length{
			bins len4	= {6'd4	};
			bins len8	= {6'd8	};
			bins len16	= {6'd16};
			bins len32	= {6'd32};
			illegal_bins illegel = default;			
		}
	endgroup
	
	//6: for formatter grant delay time
	covergroup cg_formatter_grant
		delay_req_to_grant: coverpoint delay_req_to_grant{
			bins delay_1 		= {1};
			bins delay_2 		= {2};
			bins delay_3_plus 	= {3:10};
			illegal_bins illegal = {0};
		}
	endgroup
	
	//----------------------------------------------
	// Methods
	// ---------------------------------------------
	// Standard UVM Methods:	
	extern function new(string name = "mcdf_cov", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern function void report_phase(uvm_phase phase);
	// User Defined Methods:
	extern virtual function void set_interface(	virtual chnl_intf 	chnl_vifs[3],
												virtual reg_intf 	reg_vif	    ,
												virtual arb_intf 	arb_vif     ,
												virtual fmt_intf 	fmt_vif	    ,
												virtual mcdf_intf 	mcdf_vif	
												);
	// Covergroup Sample Methods:
	extern task do_reg_sample();
	extern task do_channel_sample();	
	extern task do_arbiter_sample();
	extern task do_formatter_sample();

endclass

//////////////////////////////////////////////////////////////////////////////////
// Methods realization
//////////////////////////////////////////////////////////////////////////////////
//Constructor
function void mcdf_cov::new(string name = "mcdf_cov", uvm_component parent)
	super.new(name, parent);
endfunction

//Build_Phase
function void mcdf_cov::build_phase(uvm_phase phase);
	super.build_phase(phase);	
	cg_arbiter_priority			= new();
	cg_channel_disable          = new();
	cg_formatter_grant          = new();
	cg_formatter_length         = new();
	cg_mcdf_reg_illegal_access  = new();
	cg_mcdf_reg_write_read      = new();
endfunction

//Run_phase
function void mcdf_cov::run_phase(uvm_phase phase);
	fork
		do_reg_sample();
	    do_channel_sample();	
	    do_arbiter_sample();
	    do_formatter_sample();
	join
endfunction

//report_phase
function void mcdf_cov::report_phase(uvm_phase phase);
	super.report_phase(phase);
	string s;
	s = "\n--------------------------------------------------\n"
	s = {s, "COVERAGE SUMMARY \n"};		
	s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())};	
	s = {s, $sformatf("cg_arbiter_priority 			coverage: %.1f \n", cg_arbiter_priority.get_coverage())			};	
	s = {s, $sformatf("cg_channel_disable  			coverage: %.1f \n", cg_channel_disable.get_coverage())			};	
	s = {s, $sformatf("cg_formatter_grant  			coverage: %.1f \n", cg_formatter_grant.get_coverage())			};	
	s = {s, $sformatf("cg_formatter_length 			coverage: %.1f \n", cg_formatter_length.get_coverage())			};	
	s = {s, $sformatf("cg_mcdf_reg_illegal_access 	coverage: %.1f \n", cg_mcdf_reg_illegal_access.get_coverage())	};	
	s = {s, $sformatf("cg_mcdf_reg_write_read     	coverage: %.1f \n", cg_mcdf_reg_write_read.get_coverage())		};	
	s = "\n--------------------------------------------------\n"
	`uvm_info(get_type_name(), s)
	
endfunction

// User Defined Methods:
function void mcdf_cov::set_interface(	virtual chnl_intf 	chnl_vifs[3],
										virtual reg_intf 	reg_vif	    ,
										virtual arb_intf 	arb_vif     ,
										virtual fmt_intf 	fmt_vif	    ,
										virtual mcdf_intf 	mcdf_vif	
											);
	this.chnl_vifs	= chnl_vifs; 
	this.reg_vif	= reg_vif;       
	this.arb_vif    = arb_vif;  
	this.fmt_vif	= fmt_vif;       
	this.mcdf_vif	= mcdf_vif;

	if(chnl_vifs[0] == null || chnl_vifs[1] == null || chnl_vifs[2] == null)
		$error("chnl interface handle is NULL, please check if target interface has been intantiated");
	if(arb_vif == null)
		$error("arb interface handle is NULL, please check if target interface has been intantiated");
	if(reg_vif == null)
		$error("reg interface handle is NULL, please check if target interface has been intantiated");
	if(fmt_vif == null)
		$error("fmt interface handle is NULL, please check if target interface has been intantiated");
	if(mcdf_vif == null)
		$error("mcdf interface handle is NULL, please check if target interface has been intantiated");
											
endfunction
// Covergroup Sample Methods:

task mcdf_cov::do_reg_sample();
	forever begin
		@(posedge reg_vif.clk iff reg_vif.rstn);
		cg_mcdf_reg_illegal_access.sample();
		cg_mcdf_reg_write_read.sample();    
	end
endtask
 
task mcdf_cov::do_channel_sample();	
	forever begin
		@(posedge mcdf_vif.clk iff mcdf_vif.rstn);
		if(chnl_vifs[0].mon_cb.ch_valid===1 || chnl_vifs[1].mon_cb.ch_valid===1 || chnl_vifs[2].mon_cb.ch_valid===1)
			cg_channel_disable.sample();
	end
endtask
 
task mcdf_cov::do_arbiter_sample();
	forever begin
		@(posedge arb_vif.clk iff arb_vif.rstn);
		if(arb_vif.slv_req[0]!==0 || arb_vif.slv_req[1]!==0 || arb_vif.slv_req[2]!==0)
			cg_arbiter_priority.sample();
	end
endtask
 
task mcdf_cov::do_formatter_sample();
	fork 
		forever begin
			@(posedge fmt_vif.clk iff fmt_vif.rstn);
			if(fmt_vif.mon_cb.fmt_req === 1);
				this.cg_formatter_length.sample();			
		end
		
		forever begin
			@(posedge fmt_vif.clk iff fmt_vif.rstn);
			delay_req_to_grant = 0;
			forever begin
				if(fmt_vif.fmt_grant === 1) begin
					this.cg_formatter_grant.sample();
				end else begin
					@(posedge fmt_vif.clk);
					delay_req_to_grant++;
				end
			end
		end
	join
endtask