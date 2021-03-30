
//------------------------------------------------------------------------------------------------------------------------//
//change log 2017-08-20 Move package length select to Arbiter  
//------------------------------------------------------------------------------------------------------------------------//

`define  ADDR_WIDTH 8
`define  CMD_DATA_WIDTH 32
`define  DATA_WIDTH 8

`define  WRITE 2'b10          //Register operation command
`define  READ  2'b01
`define  IDLE  2'b00

`define SLV0_RW_ADDR 8'h00    //Register address 
`define SLV1_RW_ADDR 8'h04
`define SLV2_RW_ADDR 8'h08
`define SLV0_R_ADDR  8'h10
`define SLV1_R_ADDR  8'h14
`define SLV2_R_ADDR  8'h18


`define SLV0_RW_REG 0
`define SLV1_RW_REG 1
`define SLV2_RW_REG 2
`define SLV0_R_REG  3
`define SLV1_R_REG  4
`define SLV2_R_REG  5

`define FIFO_MARGIN_WIDTH 8

`define PRIO_WIDTH 2
`define PRIO_HIGH 2
`define PRIO_LOW  1

`define PAC_LEN_WIDTH 3
`define PAC_LEN_HIGH 5
`define PAC_LEN_LOW  3    

module mcdf(
  input 						clk_i		,
  input 						clk_25m_i	,
  input 						clk_33m_i	,
  input 						rstn_i		,
  
  input [1:0]  					cmd_i		,
  input [`ADDR_WIDTH-1:0] 		cmd_addr_i	,
  input [`CMD_DATA_WIDTH-1:0] 	cmd_data_i	,
  output[`CMD_DATA_WIDTH-1:0] 	cmd_data_o	,

  

  input [`DATA_WIDTH-1:0] 		ch0_data_i	,
  input  						ch0_vld_i	,
  input [`DATA_WIDTH-1:0] 		ch1_data_i	,
  input  						ch1_vld_i	,
  input [`DATA_WIDTH-1:0] 		ch2_data_i	,
  input  						ch2_vld_i	,
  output 						ch0_ready_o	,
  output 						ch1_ready_o	,
  output 						ch2_ready_o	,

  input  						fmt_grant_i	,
  output [1:0] 					fmt_chid_o	,
  output 						fmt_req_o	,
  output [31:0]  				fmt_length_o,
  output [7:0]  				fmt_data_o	,
  output 						fmt_start_o	,
  output 						fmt_end_o 	,
  //4b/3b
  output [2:0]					tx_data		,
  output						tx_enable	,
  
  input	[31:0]					loc_low_timer	,
  input [31:0]					loc_high_timer	,
  output reg					loc_rcvr_status	,
  // scrambler + mapping
  input [1:0]					tx_mode			, 
  input							rcv_vld			,
  input 						scr_valid      	,
  input 						master_slave_sw	,	//1:slave, 0:master
  input [32:0]					seed           	,
  output[1:0]    				TAn           	,
  output[1:0]    				TBn            	 // -1 01, 0 00, +1 11 

  );






//--------------register To slave_fifo
wire  slv0_en_s;
wire  slv1_en_s;
wire  slv2_en_s;
wire [5:0] slv0_margin_s;
wire [5:0] slv1_margin_s;
wire [5:0] slv2_margin_s;

//--------------register To arbiter 
wire [`PRIO_WIDTH-1:0] slv0_prio_s;
wire [`PRIO_WIDTH-1:0] slv1_prio_s;
wire [`PRIO_WIDTH-1:0] slv2_prio_s;
wire  [`PAC_LEN_WIDTH-1:0]  slv0_pkglen_s;
wire  [`PAC_LEN_WIDTH-1:0]  slv1_pkglen_s;
wire  [`PAC_LEN_WIDTH-1:0]  slv2_pkglen_s;

//--------------slave_fifo to arbiter 
wire [7:0]  slv0_data_s;
wire [7:0]  slv1_data_s;
wire [7:0]  slv2_data_s;

wire slv0_req_s;
wire slv1_req_s;
wire slv2_req_s;

wire slv0_val_s;
wire slv1_val_s;
wire slv2_val_s;

wire a2s0_ack_s;
wire a2s1_ack_s;
wire a2s2_ack_s;

//--------------formater to arbiter
wire   			f2a_ack_s;
wire    			a2f_val_s;
wire    			f2a_id_req_s;
wire[7:0] 		a2f_data_s;
wire[1:0]   	a2f_id_s;
wire[2:0] 		pkglen_sel_s;

rst_sync_gen rst_sync_gen_inst(

 .sys_clk_25m        (clk_25m_i	),
 .sys_clk_33m        (clk_33m_i	),
 .reset_n            (rstn_i	),

 .rst_n_25m          (rst_n_25m	),   
 .rst_n_33m          (rst_n_33m	)
);

ctrl_regs ctrl_regs_inst(
	.clk_i(clk_i),   
	.rstn_i(rstn_i),
	.cmd_i(cmd_i),
	.cmd_addr_i(cmd_addr_i),
	.cmd_data_i(cmd_data_i),
	.cmd_data_o(cmd_data_o),
	.slv0_pkglen_o(slv0_pkglen_s),
	.slv1_pkglen_o(slv1_pkglen_s),
	.slv2_pkglen_o(slv2_pkglen_s),
	.slv0_prio_o(slv0_prio_s),
	.slv1_prio_o(slv1_prio_s),
	.slv2_prio_o(slv2_prio_s),		
	.slv0_margin_i({2'b0, slv0_margin_s}),
	.slv1_margin_i({2'b0, slv1_margin_s}),
	.slv2_margin_i({2'b0, slv2_margin_s}),
	.slv0_en_o(slv0_en_s),
	.slv1_en_o(slv1_en_s),
	.slv2_en_o(slv2_en_s));

 slave_fifo slv0_inst(
         .clk_i(clk_i),
         .rstn_i(rstn_i),
         .chx_data_i(ch0_data_i),
         .chx_valid_i(ch0_vld_i),
         
         .chx_ready_o(ch0_ready_o),
         .slvx_en_i(slv0_en_s),
         .margin_o(slv0_margin_s),
         .a2sx_ack_i(a2s0_ack_s),
         .slvx_req_o(slv0_req_s),
         .slvx_val_o(slv0_val_s),
         .slvx_data_o(slv0_data_s)
          );
 slave_fifo slv1_inst(
         .clk_i(clk_i),
         .rstn_i(rstn_i),
         .chx_data_i(ch1_data_i),
         .chx_valid_i(ch1_vld_i),
         
         .chx_ready_o(ch1_ready_o),
         .slvx_en_i(slv1_en_s),
         .margin_o(slv1_margin_s),
         .slvx_req_o(slv1_req_s),
         .a2sx_ack_i(a2s1_ack_s),
         .slvx_val_o(slv1_val_s),
         .slvx_data_o(slv1_data_s)
          );
 slave_fifo slv2_inst(
         .clk_i(clk_i),
         .rstn_i(rstn_i),
         .chx_data_i(ch2_data_i),
         .chx_valid_i(ch2_vld_i),
         
         .chx_ready_o(ch2_ready_o),
         .slvx_en_i(slv2_en_s),
         .margin_o(slv2_margin_s),
         .slvx_req_o(slv2_req_s),
         .a2sx_ack_i(a2s2_ack_s),
         .slvx_val_o(slv2_val_s),
         .slvx_data_o(slv2_data_s)
          );
             
arbiter arbiter_inst(
  .clk_i(clk_i),
  .rstn_i(rstn_i),
                           
  //connect ith registers
  .slv0_prio_i(slv0_prio_s),
  .slv1_prio_i(slv1_prio_s),
  .slv2_prio_i(slv2_prio_s),

  //connect with slave port
  .slv0_data_i(slv0_data_s),
  .slv1_data_i(slv1_data_s),
  .slv2_data_i(slv2_data_s),
  .slv0_req_i(slv0_req_s),
  .slv1_req_i(slv1_req_s),
  .slv2_req_i(slv2_req_s),
  .slv0_val_i(slv0_val_s),
  .slv1_val_i(slv1_val_s),
  .slv2_val_i(slv2_val_s),
  .slv0_pkglen_i(slv0_pkglen_s),
  .slv1_pkglen_i(slv1_pkglen_s),
  .slv2_pkglen_i(slv2_pkglen_s),  
                           
  .a2s0_ack_o(a2s0_ack_s),
  .a2s1_ack_o(a2s1_ack_s),
  .a2s2_ack_o(a2s2_ack_s),
                           
  //connect with formater
  .a2f_pkglen_sel_o(pkglen_sel_s),
  .f2a_ack_i(f2a_ack_s),
  .f2a_id_req_i(f2a_id_req_s),
  .a2f_val_o(a2f_val_s),
  .a2f_id_o(a2f_id_s),
  .a2f_data_o(a2f_data_s)
);

formater formater_inst(

                 .clk_i			(clk_i			),
                 .rstn_i		(rstn_i			),
                 .a2f_val_i		(a2f_val_s		),
				 .pkglen_sel_i	(pkglen_sel_s	),
                 .a2f_id_i		(a2f_id_s		),
                 .a2f_data_i	(a2f_data_s		),                          
                 .f2a_ack_o		(f2a_ack_s		),
                 .fmt_id_req_o	(f2a_id_req_s	),
                 .fmt_chid_o	(fmt_chid_o		),                  
                 .fmt_length_o	(fmt_length_o	),                  
                 .fmt_req_o		(fmt_req_o		),
                 .fmt_grant_i	(fmt_grant_i	),
                 .fmt_data_o	(fmt_data_o		),
				 .fmt_vld_o		(fmt_vld_o		),
                 .fmt_start_o	(fmt_start_o	),
                 .fmt_end_o		(fmt_end_o		)
                  );
				  
wire [7:0] 	txd_out;	
wire 		txen_out;	  
  gmii_to_mgmii u_gmii_to_mgmii_tx (
    // Inputs
    .resetn_tx    (rstn_i		),
    .gmii_mode    (1'b0			),       //0:mii_mode, 1:gmii_mode;
    
    .mac_clk_tx   (clk_i		),  //125M, 12.5M, 1.25M
    .txd_in       (fmt_data_o	),
    .txen_in      (fmt_vld_o	),
    
    .clk_gmii_2x  (clk_25m_i	),    //125M, 25M, 2.5M
    // Outputs
    .txd_out      (txd_out 		),
    .txen_out     (txen_out		),
    .txer_out     (txer_out		)
  );

 cov_4B3B_0 cov_4B3B_inst0(
/*input           */.sys_clk_25m   (clk_25m_i  		),
/*input           */.rst_n_25m     (rst_n_25m    	),
/*input           */.sys_clk_33m   (clk_33m_i  		),
/*input           */.rst_n_33m     (rst_n_33m    	),
/*input     [3:0] */.TXD           (txd_out[3:0]	),
/*input           */.tx_enable_mii (txen_out		),
/*output reg[2:0] */.tx_data       (tx_data  		),
/*output reg      */.tx_data_en    (tx_enable		)
);



////// ===========loc_rcvr_status============///////
reg [32:0] loc_timer;
wire [2:0] 	sdn;
wire 		sxn;
wire [32:0] loc_timer_sum;

assign  loc_timer_sum = loc_high_timer+loc_low_timer;

always @ (posedge clk_33m_i or negedge rst_n_33m)
 begin  if (! rst_n_33m)  
             loc_timer<=0;
        else if (!tx_enable)// LOC_TIMER COUNTING after sendz
		     loc_timer<=0;
		else if (loc_timer>=loc_timer_sum)	 
		     loc_timer<=0;
	    else if (scr_valid) loc_timer<=loc_timer+1;
 end

always @ (posedge clk_33m_i or negedge rst_n_33m)
 begin  if (! rst_n_33m)  
             loc_rcvr_status<=0;
        else if (loc_timer <= loc_low_timer)
		     loc_rcvr_status<=0;
	    else loc_rcvr_status<=1'b1;
 end 

scr_data_gen scr_data_gen_inst0(

 /* input        */ .rst_n          (rst_n_33m  		),
 /* input        */ .clk            (clk_33m_i			),
 /* input  [2:0] */ .tx_data        (tx_data			),
 /* input  [1:0] */ .tx_mode        (tx_mode & {rcv_vld,rcv_vld}	), 
 //                 .valid          (scr_valid 			),
					.valid          (tx_enable 			),
					.master_slave_sw(master_slave_sw	),	
 /* input        */ .load           (1'b0					),
 /* input [32:0] */ .seed           (seed				),
 /* input        */ .loc_rcvr_status(1'b1	),
 /* input        */ .tx_enable      (tx_enable      	), // tx_enable_r0 ,  tx_enable_esd for extra 3 esd data^scr
 /* output       */ .sxn            (sxn            	),
 /* output [2:0] */ .sdn            (sdn            	) 
  
  );
  
syb_mapping  syb_mapping_inst0(
  /*  input             */ .rst_n      (rst_n_33m   ),
  /*  input             */ .clk        (clk_33m_i 	),
  /*  input      [2:0]  */ .tx_mode    (tx_mode & {rcv_vld,rcv_vld}),
///* input              */ .tx_error   (tx_error  	),
  /*  input             */ .tx_enable  (tx_enable	),// tx_enable_r0 ,  tx_enable_esd for extra 3 esd data^scr
  /*  input    [2:0]    */ .sdn        (sdn       	),
  /*  input             */ .sxn        (sxn       	),
  /*  output reg [1:0]  */ .TAn        (TAn       	),
  /*  output reg [1:0]  */ .TBn        (TBn       	) 
 );
 
 
endmodule

