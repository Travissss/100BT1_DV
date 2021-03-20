//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	02/17/2021 Wed 19:31
// Filename: 		arb_pkg.sv
// class Name: 		arb_pkg
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> VIP for mcdf arbiter
//////////////////////////////////////////////////////////////////////////////////

`ifndef MCDF_ARB_SV
`define MCDF_ARB_SV

`include "arb_intf.sv"
package arb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"


    class arb_trans extends uvm_sequence_item;
        `uvm_object_utils(arb_trans)
        // new - constructor
        function new (string name = "arb_trans");
            super.new(name);
        endfunction
        // ... ignored
    endclass

    class arb_driver extends uvm_driver #(arb_trans);
        `uvm_component_utils(arb_driver)
        function new (string name = "arb_driver", uvm_component parent);
            super.new(name, parent);
        endfunction
        // ... ignored
    endclass

    class arb_sequencer extends uvm_sequencer #(arb_trans);
        `uvm_component_utils(arb_sequencer)
        function new (string name = "arb_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction
        // ... ignored
    endclass

    class arb_monitor extends uvm_monitor;
        `uvm_component_utils(arb_monitor)
        function new (string name = "arb_monitor", uvm_component parent);
            super.new(name, parent);
        endfunction
        // ... ignored
    endclass

    class arb_agt extends uvm_agent;
        `uvm_component_utils(arb_agt)
        function new (string name = "arb_agent", uvm_component parent);
            super.new(name, parent);
        endfunction
        // ... ignored
    endclass

	
endpackage

`endif