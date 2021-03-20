//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/25/2021 TUE 19:27
// Filename: 		fmt_pkg.sv
// class Name: 		fmt_pkg
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> VIP for mcdf formatter
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_FMT_PKG_SV
`define MCDF_FMT_PKG_SV

`include "fmt_intf.sv"
package fmt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    typedef enum{SHORT_FIFO, MED_FIFO, LONG_FIFO, ULTRA_FIFO}   fmt_fifo_t;
    typedef enum{LOW_WIDTH, MED_WIDTH, HIGH_WIDTH, ULTRA_WIDTH} fmt_bandwidth_t;
    
    `include "fmt_trans.sv"
    `include "fmt_drv.sv"
    `include "fmt_sqr.sv"
    `include "fmt_mon.sv"
    `include "fmt_agt.sv"
	
endpackage

`endif