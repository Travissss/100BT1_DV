//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/25/2021 Tue 19:27
// Filename: 		reg_pkg.sv
// class Name: 		reg_pkg
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> VIP for mcdf register
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_REG_PKG_SV
`define MCDF_REG_PKG_SV

`include "param_def.v"
`include "reg_intf.sv"
package reg_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    
    `include "reg_trans.sv"
    `include "reg_drv.sv"
    `include "reg_sqr.sv"
    `include "reg_mon.sv"
    `include "reg_agt.sv"
	
endpackage

`endif