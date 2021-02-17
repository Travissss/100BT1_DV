package chnl_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // channel sequence item
  class chnl_trans extends uvm_sequence_item;
    rand bit[31:0] data[];
    rand int ch_id;
    rand int pkt_id;
    rand int data_nidles;
    rand int pkt_nidles;
    bit rsp;

    constraint cstr{
      soft data.size inside {[4:32]};
      foreach(data[i]) data[i] == 'hC000_0000 + (this.ch_id<<24) + (this.pkt_id<<8) + i;
      soft ch_id == 0;
      soft pkt_id == 0;
      soft data_nidles inside {[0:2]};
      soft pkt_nidles inside {[1:10]};
    };

    `uvm_object_utils_begin(chnl_trans)
      `uvm_field_array_int(data, UVM_ALL_ON)
      `uvm_field_int(ch_id, UVM_ALL_ON)
      `uvm_field_int(pkt_id, UVM_ALL_ON)
      `uvm_field_int(data_nidles, UVM_ALL_ON)
      `uvm_field_int(pkt_nidles, UVM_ALL_ON)
      `uvm_field_int(rsp, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "chnl_trans");
      super.new(name);
    endfunction
  endclass: chnl_trans
  
  // channel driver
  class chnl_driver extends uvm_driver #(chnl_trans);
    local virtual chnl_intf intf;
    mailbox #(chnl_trans) req_mb;
    mailbox #(chnl_trans) rsp_mb;

    `uvm_component_utils(chnl_driver)
  
    function new (string name = "chnl_driver", uvm_component parent);
      super.new(name, parent);
    endfunction
  
    function void set_interface(virtual chnl_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      fork
       this.do_drive();
       this.do_reset();
      join
    endtask

    task do_reset();
      forever begin
        @(negedge intf.rstn);
        intf.ch_valid <= 0;
        intf.ch_data <= 0;
      end
    endtask

    task do_drive();
      chnl_trans req, rsp;
      @(posedge intf.rstn);
      forever begin
        this.req_mb.get(req);
        this.chnl_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        this.rsp_mb.put(rsp);
      end
    endtask
  
    task chnl_write(input chnl_trans t);
      foreach(t.data[i]) begin
        @(posedge intf.clk);
        intf.drv_ck.ch_valid <= 1;
        intf.drv_ck.ch_data <= t.data[i];
        @(negedge intf.clk);
        wait(intf.ch_ready === 'b1);
        `uvm_info(get_type_name(), $sformatf("sent data 'h%8x", t.data[i]), UVM_HIGH)
        repeat(t.data_nidles) chnl_idle();
      end
      repeat(t.pkt_nidles) chnl_idle();
    endtask
    
    task chnl_idle();
      @(posedge intf.clk);
      intf.drv_ck.ch_valid <= 0;
      intf.drv_ck.ch_data <= 0;
    endtask
  endclass: chnl_driver
  
  // channel generator and to be replaced by sequence + sequencer later
  class chnl_generator extends uvm_component;
    rand int pkt_id = 0;
    rand int ch_id = -1;
    rand int data_nidles = -1;
    rand int pkt_nidles = -1;
    rand int data_size = -1;
    rand int ntrans = 10;

    mailbox #(chnl_trans) req_mb;
    mailbox #(chnl_trans) rsp_mb;

    constraint cstr{
      soft ch_id == -1;
      soft pkt_id == 0;
      soft data_size == -1;
      soft data_nidles == -1;
      soft pkt_nidles == -1;
      soft ntrans == 10;
    }

    `uvm_component_utils_begin(chnl_generator)
      `uvm_field_int(pkt_id, UVM_ALL_ON)
      `uvm_field_int(ch_id, UVM_ALL_ON)
      `uvm_field_int(data_nidles, UVM_ALL_ON)
      `uvm_field_int(pkt_nidles, UVM_ALL_ON)
      `uvm_field_int(data_size, UVM_ALL_ON)
      `uvm_field_int(ntrans, UVM_ALL_ON)
    `uvm_component_utils_end

    function new (string name = "chnl_generator", uvm_component parent);
      super.new(name, parent);
      this.req_mb = new();
      this.rsp_mb = new();
    endfunction

    task start();
      repeat(ntrans) send_trans();
    endtask

    task send_trans();
      chnl_trans req, rsp;
      req = chnl_trans::type_id::create("req");;
      assert(req.randomize with {local::ch_id >= 0 -> ch_id == local::ch_id; 
                                 local::pkt_id >= 0 -> pkt_id == local::pkt_id;
                                 local::data_nidles >= 0 -> data_nidles == local::data_nidles;
                                 local::pkt_nidles >= 0 -> pkt_nidles == local::pkt_nidles;
                                 local::data_size >0 -> data.size() == local::data_size; 
                               })
        else $fatal("[RNDFAIL] channel packet randomization failure!");
      this.pkt_id++;
      `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
      this.req_mb.put(req);
      this.rsp_mb.get(rsp);
      `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask

    function void post_randomize();
      string s;
      s = {s, "AFTER RANDOMIZATION \n"};
      s = {s, "=======================================\n"};
      s = {s, "chnl_generator object content is as below: \n"};
      s = {s, super.sprint()};
      s = {s, "=======================================\n"};
      `uvm_info(get_type_name(), s, UVM_HIGH)
    endfunction
  endclass: chnl_generator

  typedef struct packed {
    bit[31:0] data;
    bit[1:0] id;
  } mon_data_t;

  // channel monitor
  class chnl_monitor extends uvm_monitor;
    local virtual chnl_intf intf;
    //TODO-1.1 to implement uvm_blocking_put_PORT here and later to be
    //connected to target export/imp
    mailbox #(mon_data_t) mon_mb;

    `uvm_component_utils(chnl_monitor)

    function new(string name="chnl_monitor", uvm_component parent);
      super.new(name, parent);
      //TODO-1.1 instantiate the TLM port
    endfunction

    function void set_interface(virtual chnl_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      this.mon_trans();
    endtask

    task mon_trans();
      mon_data_t m;
      forever begin
        @(posedge intf.clk iff (intf.mon_ck.ch_valid==='b1 && intf.mon_ck.ch_ready==='b1));
        m.data = intf.mon_ck.ch_data;
        //TODO-1.1 instantiate the TLM port
        mon_mb.put(m);
        `uvm_info(get_type_name(), $sformatf("monitored channel data 'h%8x", m.data), UVM_HIGH)
      end
    endtask
  endclass: chnl_monitor
  
  // channel agent
  class chnl_agent extends uvm_agent;
    chnl_driver driver;
    chnl_monitor monitor;
    local virtual chnl_intf vif;

    `uvm_component_utils(chnl_agent)

    function new(string name = "chnl_agent", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      driver = chnl_driver::type_id::create("driver", this);
      monitor = chnl_monitor::type_id::create("monitor", this);
    endfunction

    function void set_interface(virtual chnl_intf vif);
      this.vif = vif;
      driver.set_interface(vif);
      monitor.set_interface(vif);
    endfunction
  endclass: chnl_agent

endpackage

