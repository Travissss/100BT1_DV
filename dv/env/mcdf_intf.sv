//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/04/2021 Thu 21:45
// Filename: 		mcdf_intf.sv
// class Name: 		mcdf_intf
// Project Name: 	mcdf_uvm
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> generate clock and resetn
//////////////////////////////////////////////////////////////////////////////////

interface mcdf_intf(output logic clk, output logic rstn);
    
    logic chnl_en[3];
	
	clocking mon_cb@(posedge clk);
		default input #1 output #1;
        input   chnl_en;
	endclocking
	
    // clock generation
    initial begin
        clk <= 0;
        forever begin
            #5 clk <= ~clk;
        end
    end
    
    // reset signal
    initial begin
        #10 rstn <= 0;
        repeat(10) @(posedge clk);
        rstn <= 1;
    end

endinterface
