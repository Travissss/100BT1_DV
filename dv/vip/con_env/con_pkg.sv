//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/28/2021 Sun 15:06
// Filename: 		con_pkg.sv
// class Name: 		con_pkg
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> VIP for mcdf channel
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CON_SV
`define MCDF_CON_SV

`include "con_intf.sv"
package con_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
  
    `include "con_trans.sv"
    `include "con_drv.sv"
    `include "con_sqr.sv"
    `include "con_mon.sv"
    `include "con_agt.sv"
	
endpackage

`endif