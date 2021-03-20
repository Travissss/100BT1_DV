//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/10/2021 Wed 21:22
// Filename: 		arb_intf.sv
// class Name: 		arb_intf
// Project Name: 	mcdf_uvm
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Connect medias in UVC
//////////////////////////////////////////////////////////////////////////////////

interface arb_intf(input clk, input rstn);
	logic	[1:0]	slv_prios[3];
	logic			slv_reqs[3];
	logic 			a2s_acks[3];
	logic			f2a_id_req;
	
	clocking mon_cb@(posedge clk);
		// default input #1 output #1;
        input  slv_prios;
        input  slv_reqs;
        input  a2s_acks;
		input  f2a_id_req;
	endclocking

endinterface

