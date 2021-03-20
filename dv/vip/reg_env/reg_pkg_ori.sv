

`include "param_def.v"
interface reg_intf(input clk, input rstn);
  logic [1:0]                 cmd;
  logic [`ADDR_WIDTH-1:0]     cmd_addr;
  logic [`CMD_DATA_WIDTH-1:0] cmd_data_s2m;
  logic [`CMD_DATA_WIDTH-1:0] cmd_data_m2s;
  clocking drv_cb @(posedge clk);
    default input #1ns output #1ns;
    output cmd, cmd_addr, cmd_data_m2s;
    input cmd_data_s2m;
  endclocking
  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns;
    input cmd, cmd_addr, cmd_data_m2s, cmd_data_s2m;
  endclocking
endinterface


package reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // register sequence item
  class reg_trans extends uvm_sequence_item;
    rand bit[7:0] addr;
    rand bit[1:0] cmd;
    rand bit[31:0] data;
    bit rsp;

    constraint cstr {
      soft cmd inside {`WRITE, `READ, `IDLE};
      soft addr inside {`SLV0_RW_ADDR, `SLV1_RW_ADDR, `SLV2_RW_ADDR, `SLV0_R_ADDR, `SLV1_R_ADDR, `SLV2_R_ADDR};
      addr[7:4]==0 && cmd==`WRITE -> soft data[31:6]==0;
      soft addr[7:5]==0;
      addr[4]==1 -> soft cmd == `READ;
    };

    `uvm_object_utils_begin(reg_trans)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(cmd, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(rsp, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "reg_trans");
      super.new(name);
    endfunction
  endclass

  // register driver
  class reg_drv extends uvm_driver #(reg_trans);
    local virtual reg_intf intf;

    `uvm_component_utils(reg_drv)
  
    function new (string name = "reg_drv", uvm_component parent);
      super.new(name, parent);
    endfunction
  
    function void set_interface(virtual reg_intf intf);
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
        intf.cmd_addr <= 0;
        intf.cmd <= `IDLE;
        intf.cmd_data_m2s <= 0;
      end
    endtask

    task do_drive();
      reg_trans req, rsp;
      @(posedge intf.rstn);
      forever begin
        seq_item_port.get_next_item(req);
        this.reg_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
      end
    endtask
  
    task reg_write(reg_trans t);
      @(posedge intf.clk iff intf.rstn);
      case(t.cmd)
        `WRITE: begin 
                  intf.drv_cb.cmd_addr <= t.addr; 
                  intf.drv_cb.cmd <= t.cmd; 
                  intf.drv_cb.cmd_data_m2s <= t.data; 
                end
        `READ:  begin 
                  intf.drv_cb.cmd_addr <= t.addr; 
                  intf.drv_cb.cmd <= t.cmd; 
                  repeat(2) @(negedge intf.clk);
                  t.data = intf.cmd_data_s2m; 
                end
        `IDLE:  begin 
                  this.reg_idle(); 
                end
        default: $error("command %b is illegal", t.cmd);
      endcase
      `uvm_info(get_type_name(), $sformatf("sent addr %2x, cmd %2b, data %8x", t.addr, t.cmd, t.data), UVM_HIGH)
    endtask
    
    task reg_idle();
      @(posedge intf.clk);
      intf.drv_cb.cmd_addr <= 0;
      intf.drv_cb.cmd <= `IDLE;
      intf.drv_cb.cmd_data_m2s <= 0;
    endtask
  endclass

  class reg_sqr extends uvm_sequencer #(reg_trans);
    `uvm_component_utils(reg_sqr)
    function new (string name = "reg_sqr", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass: reg_sqr

  class reg_base_sequence extends uvm_sequence #(reg_trans);
    rand bit[7:0] addr = -1;
    rand bit[1:0] cmd = -1;
    rand bit[31:0] data = -1;

    constraint cstr{
      soft addr == -1;
      soft cmd == -1;
      soft data == -1;
    }

    `uvm_object_utils_begin(reg_base_sequence)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(cmd, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(reg_sqr)

    function new (string name = "reg_base_sequence");
      super.new(name);
    endfunction

    task body();
      send_trans();
    endtask

    // generate transaction and put into local mailbox
    task send_trans();
      reg_trans req, rsp;
      `uvm_do_with(req, {local::addr >= 0 -> addr == local::addr;
                         local::cmd >= 0 -> cmd == local::cmd;
                         local::data >= 0 -> data == local::data;
                         })
      `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
      get_response(rsp);
      `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
      if(req.cmd == `READ) 
        this.data = rsp.data;
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask

    function void post_randomize();
      string s;
      s = {s, "AFTER RANDOMIZATION \n"};
      s = {s, "=======================================\n"};
      s = {s, "reg_base_sequence object content is as below: \n"};
      s = {s, super.sprint()};
      s = {s, "=======================================\n"};
      `uvm_info(get_type_name(), s, UVM_HIGH)
    endfunction
  endclass: reg_base_sequence

  class reg_idle_sequence extends reg_base_sequence;
    constraint cstr{
      addr == 0;
      cmd == `IDLE;
      data == 0;
    }
    `uvm_object_utils(reg_idle_sequence)
    function new (string name = "reg_idle_sequence");
      super.new(name);
    endfunction
  endclass: reg_idle_sequence

  class reg_write_sequence extends reg_base_sequence;
    constraint cstr{
      cmd == `WRITE;
    }
    `uvm_object_utils(reg_write_sequence)
    function new (string name = "reg_write_sequence");
      super.new(name);
    endfunction
  endclass: reg_write_sequence

  class reg_read_sequence extends reg_base_sequence;
    constraint cstr{
      cmd == `READ;
    }
    `uvm_object_utils(reg_read_sequence)
    function new (string name = "reg_read_sequence");
      super.new(name);
    endfunction
  endclass: reg_read_sequence 

  // register monitor
  class reg_mon extends uvm_monitor;
    local virtual reg_intf intf;
    uvm_blocking_put_port #(reg_trans) mon_bp_port;
    uvm_analysis_port #(reg_trans) mon_ap;

    `uvm_component_utils(reg_mon)

    function new(string name="reg_mon", uvm_component parent);
      super.new(name, parent);
      mon_bp_port = new("mon_bp_port", this);
      mon_ap = new("mon_ap", this);
    endfunction

    function void set_interface(virtual reg_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      this.mon_trans();
    endtask

    task mon_trans();
      reg_trans m;
      forever begin
        @(posedge intf.clk iff (intf.rstn && intf.mon_cb.cmd != `IDLE));
        m = new();
        m.addr = intf.mon_cb.cmd_addr;
        m.cmd = intf.mon_cb.cmd;
        if(intf.mon_cb.cmd == `WRITE) begin
          m.data = intf.mon_cb.cmd_data_m2s;
        end
        else if(intf.mon_cb.cmd == `READ) begin
          @(posedge intf.clk);
          m.data = intf.mon_cb.cmd_data_s2m;
        end
        mon_bp_port.put(m);
        mon_ap.write(m);
        `uvm_info(get_type_name(), $sformatf("monitored addr %2x, cmd %2b, data %8x", m.addr, m.cmd, m.data), UVM_HIGH)
      end
    endtask
  endclass: reg_mon

  // register agent
  class reg_agt extends uvm_agent;
    reg_drv drv_i;
    reg_mon mon_i;
    reg_sqr sqr_i;
    local virtual reg_intf vif;

    `uvm_component_utils(reg_agt)

    function new(string name = "reg_agt", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv_i = reg_drv::type_id::create("drv_i", this);
      mon_i = reg_mon::type_id::create("mon_i", this);
      sqr_i = reg_sqr::type_id::create("sqr_i", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv_i.seq_item_port.connect(sqr_i.seq_item_export);
    endfunction

    function void set_interface(virtual reg_intf vif);
      this.vif = vif;
      drv_i.set_interface(vif);
      mon_i.set_interface(vif);
    endfunction
  endclass

endpackage
