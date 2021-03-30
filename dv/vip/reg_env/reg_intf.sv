//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/02/2021 Tue 20:45
// Filename: 		reg_intf.sv
// class Name: 		reg_intf
// Project Name: 	mcdf_uvm
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Connect medias in UVC
//////////////////////////////////////////////////////////////////////////////////

interface reg_intf(input clk, input rstn);
    logic   [1:0]   cmd;
    logic   [7:0]   cmd_addr;    
	logic	[31:0]	cmd_data_s2m;
    logic	[31:0]	cmd_data_m2s;
	
	logic	[31:0]	loc_low_timer;
	logic	[31:0]	loc_high_timer;
	
	clocking drv_cb@(posedge clk);
		// default input #1 output #1;
        output 		cmd;  
        output 		cmd_addr;    
        output 		cmd_data_m2s;
		output		loc_low_timer;
		output		loc_high_timer;
		
        input  		cmd_data_s2m;

	endclocking
	
	clocking mon_cb@(posedge clk);
		// default input #1 output #1;
        input  		cmd;  
        input  		cmd_addr;    
        input  		cmd_data_s2m;
        input  		cmd_data_m2s;
		input		loc_low_timer;
		input		loc_high_timer;
	endclocking

endinterface

