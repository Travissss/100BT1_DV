//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/26/2021 Tue
// Filename: 		fmt_if.sv
// class Name: 		fmt_if
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
    logic   [5:0]   fmt_length;    
	logic	[31:0]	fmt_data;
	logic			fmt_start;
	logic 			fmt_end;
	
	clocking drv_cb@(posedge clk);
		// default input #1 output #1;
        output [1:0]    fmt_chid;
        output          fmt_req;
        output [5:0]    fmt_length;       
        output [31:0]	fmt_data; 
        output 		    fmt_start;
        output 		    fmt_end;
        input           fmt_grant;
	endclocking
	
	clocking mon_cb@(posedge hclk);
		// default input #1 output #1;
        input  [1:0]    fmt_chid;
        input           fmt_req;
        input  [5:0]    fmt_length;
        input  [31:0]	fmt_data; 
        input  		    fmt_start;
        input  		    fmt_end;
        input           fmt_grant;
	endclocking

endinterface

