
interface arb_intf(input clk, input rstn);
	logic	[1:0]	slv_prios[3];
	logic			slv_reqs[3];
	logic 			a2s_acks[3];
	logic			f2a_id_req;
	
	clocking mon_cb@(posedge clk);
		default input #1 output #1;
        input  slv_prios;
        input  slv_reqs;
        input  a2s_acks;
		input  f2a_id_req;
	endclocking

endinterface

package arb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class arb_trans extends uvm_sequence_item;
    `uvm_object_utils(arb_trans)
    // new - constructor
    function new (string name = "template_transfer_inst");
      super.new(name);
    endfunction
    // ... ignored
  endclass

  class arb_drv extends uvm_driver #(arb_trans);
    `uvm_component_utils(arb_drv)
    function new (string name = "arb_drv", uvm_component parent);
      super.new(name, parent);
    endfunction
    // ... ignored
  endclass

  class arb_sqr extends uvm_sequencer #(arb_trans);
    `uvm_component_utils(arb_sqr)
    function new (string name = "arb_sqr", uvm_component parent);
      super.new(name, parent);
    endfunction
    // ... ignored
  endclass

  class arb_mon extends uvm_monitor;
    `uvm_component_utils(arb_mon)
    function new (string name = "arb_mon", uvm_component parent);
      super.new(name, parent);
    endfunction
    // ... ignored
  endclass

  class arb_agt extends uvm_agent;
    `uvm_component_utils(arb_agt)
    function new (string name = "arb_agt", uvm_component parent);
      super.new(name, parent);
    endfunction
    // ... ignored
  endclass
endpackage
