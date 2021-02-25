//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/17/2021 Wed 19:46
// Filename: 		chnl_pkg.sv
// class Name: 		chnl_pkg
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> VIP for mcdf channel
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_CHNL_SV
`define MCDF_CHNL_SV

`include "chnl_if.sv"
package chnl_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    typedef struct packed{
        bit [31:0]  data;
        bit [1:0]   id;
    } mon_data_t;
    
    `include "chnl_trans.sv"
    `include "chnl_drv.sv"
    `include "chnl_sqr.sv"
    `include "chnl_mon.sv"
    `include "chnl_agt.sv"
	
endpackage

`endif