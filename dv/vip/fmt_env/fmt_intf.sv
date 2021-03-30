//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/26/2021 Fri
// Filename: 		fmt_intf.sv
// class Name: 		fmt_intf
// Project Name: 	mcdf_uvm
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Connect medias in UVC
//////////////////////////////////////////////////////////////////////////////////

interface fmt_intf(input clk, input rstn);
    logic           fmt_grant;
    logic   [1:0]   fmt_chid;
    logic           fmt_req;
    logic   [31:0]  fmt_length;    
	logic	[7:0]	fmt_data;
	logic			fmt_start;
	logic 			fmt_end;
	
	clocking drv_cb@(posedge clk);
		// default input #1 output #1;
       input    	fmt_chid;
       input    	fmt_req;
       input    	fmt_length;       
       input 		fmt_data; 
       input    	fmt_start;
       input     	fmt_end;
       output     	fmt_grant;
	endclocking
	
	clocking mon_cb@(posedge clk);
		// default input #1 output #1;
        input		fmt_chid;
        input		fmt_req;
        input		fmt_length;
        input		fmt_data; 
        input		fmt_start;
        input		fmt_end;
        input		fmt_grant;
	endclocking

endinterface

