//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/28/2021 Sun 12:27
// Filename: 		con_intf.sv
// class Name: 		con_intf
// Project Name: 	mcdf_uvm
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Connect medias in UVC
//////////////////////////////////////////////////////////////////////////////////

interface con_intf(input clk_33m, input rstn);
	logic	[32:0]	seed;
	logic	[1:0]	tx_mode;	//0:SEND_Z	1:SEND_I  2:SEND_N;
	logic			master_slave;
	logic			tx_enable;
	logic 			rcv_vld;
	logic			loc_rcvr_status;
	logic	[1:0]	TAn;
	logic	[1:0]	TBn;
	
	clocking drv_cb@(posedge clk_33m);
		// default input #1 output #1;
        output  seed;
        output  tx_mode;
        output  master_slave;
        output  rcv_vld;
		
		input	loc_rcvr_status;
		input 	tx_enable;
        input   TAn;
		input   TBn;
	endclocking
	
	clocking mon_cb@(posedge clk_33m);
		// default input #1 output #1;
        input	seed;
        input	tx_mode;
        input	master_slave;
        input	rcv_vld;
		input	loc_rcvr_status;
		input	tx_enable;
        input   TAn;
		input   TBn;
	endclocking

endinterface

