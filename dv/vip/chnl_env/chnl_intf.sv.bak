//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/23/2021 Thu 18:58
// Filename: 		chnl_intf.sv
// class Name: 		chnl_intf
// Project Name: 	mcdf_uvm
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Connect medias in UVC
//////////////////////////////////////////////////////////////////////////////////

interface chnl_intf(input clk, input rstn);
	logic	[31:0]	ch_data;
	logic			ch_valid;
	logic 			ch_ready;
	
	clocking drv_cb@(posedge clk);
		// default input #1 output #1;
        output  ch_data;
        output  ch_valid;
        input   ch_ready;
	endclocking
	
	clocking mon_cb@(posedge hclk);
		// default input #1 output #1;
        input  ch_data;
        input  ch_valid;
        input  ch_ready;
	endclocking

endinterface

