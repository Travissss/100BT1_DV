import mcdf_rgm_pkg::*;
class mcdf_base_virtual_sequence extends uvm_sequence;
    idle_reg_sequence idle_reg_seq;
    write_reg_sequence write_reg_seq;
    read_reg_sequence read_reg_seq;
    chnl_data_sequence chnl_data_seq;
    fmt_config_sequence fmt_config_seq;
    mcdf_rgm rgm;

    `uvm_object_utils(mcdf_base_virtual_sequence)
    `uvm_declare_p_sequencer(mcdf_vsqr)

    function new (string name = "mcdf_base_virtual_sequence");
      super.new(name);
    endfunction

    virtual task body();
      `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
      //TODO-2.1 connect rgm handle
      rgm = p_sequencer.mcdf_rgm;

      this.do_reg();
      this.do_formatter();
      this.do_data();

      `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    endtask

    // do register configuration
    virtual task do_reg();
      //User to implment the task in the child virtual sequence
    endtask

    // do external formatter down stream slave configuration
    virtual task do_formatter();
      //User to implment the task in the child virtual sequence
    endtask

    // do data transition from 3 channel slaves
    virtual task do_data();
      //User to implment the task in the child virtual sequence
    endtask

    virtual function bit diff_value(int val1, int val2, string id = "value_compare");
      if(val1 != val2) begin
        `uvm_error("[CMPERR]", $sformatf("ERROR! %s val1 %8x != val2 %8x", id, val1, val2)) 
        return 0;
      end
      else begin
        `uvm_info("[CMPSUC]", $sformatf("SUCCESS! %s val1 %8x == val2 %8x", id, val1, val2), UVM_LOW)
        return 1;
      end
    endfunction
  endclass

 

  //TODO-2.2 replace the register bus sequence with uvm_reg::write()/read()
  class mcdf_data_consistence_basic_virtual_sequence extends mcdf_base_virtual_sequence;
    `uvm_object_utils(mcdf_data_consistence_basic_virtual_sequence)
    function new (string name = "mcdf_data_consistence_basic_virtual_sequence");
      super.new(name);
    endfunction
    task do_reg();
      bit[31:0] wr_val, rd_val;
      uvm_status_e status;
      // slv0 with len=8,  prio=0, en=1
      wr_val = (1<<3)+(0<<1)+1;
      rgm.chnl0_ctrl_reg.write(status, wr_val);
      rgm.chnl0_ctrl_reg.read(status, rd_val);
      void'(this.diff_value(wr_val, rd_val, "SLV0_WR_REG"));

      // slv1 with len=16, prio=1, en=1
      wr_val = (2<<3)+(1<<1)+1;
      rgm.chnl1_ctrl_reg.write(status, wr_val);
      rgm.chnl1_ctrl_reg.read(status, rd_val);
      void'(this.diff_value(wr_val, rd_val, "SLV1_WR_REG"));

      // slv2 with len=32, prio=2, en=1
      wr_val = (3<<3)+(2<<1)+1;
      rgm.chnl2_ctrl_reg.write(status, wr_val);
      rgm.chnl2_ctrl_reg.read(status, rd_val);
      void'(this.diff_value(wr_val, rd_val, "SLV2_WR_REG"));

      // send IDLE command
      `uvm_do_on(idle_reg_seq, p_sequencer.reg_sqr)
    endtask
    task do_formatter();
      `uvm_do_on_with(fmt_config_seq, p_sequencer.fmt_sqr, {fifo == LONG_FIFO; bandwidth == HIGH_WIDTH;})
    endtask
    task do_data();
      fork
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[0], {ntrans==100; ch_id==0; data_nidles==0; pkt_nidles==1; data_size==8; })
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], {ntrans==100; ch_id==1; data_nidles==1; pkt_nidles==4; data_size==16;})
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[2], {ntrans==100; ch_id==2; data_nidles==2; pkt_nidles==8; data_size==32;})
      join
      #10us; // wait until all data haven been transfered through MCDF
    endtask
  endclass: mcdf_data_consistence_basic_virtual_sequence

  class mcdf_full_random_virtual_sequence extends mcdf_base_virtual_sequence;
    `uvm_object_utils(mcdf_base_virtual_sequence)
    function new (string name = "mcdf_base_virtual_sequence");
      super.new(name);
    endfunction

    task do_reg();
      bit[31:0] ch0_wr_val;
      bit[31:0] ch1_wr_val;
      bit[31:0] ch2_wr_val;
      uvm_status_e status;

      //reset the register block
      rgm.reset();

      //slv0 with len={4,8,16,32},  prio={[0:3]}, en={[0:1]}
      ch0_wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);
      ch1_wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);
      ch2_wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);

      //set all value of WR registers via uvm_reg::set() 
      rgm.chnl0_ctrl_reg.set(ch0_wr_val);
      rgm.chnl1_ctrl_reg.set(ch1_wr_val);
      rgm.chnl2_ctrl_reg.set(ch2_wr_val);

      //update them via uvm_reg_block::update()
      rgm.update(status);

      //wait until the registers in DUT have been updated
      #100ns;

      //compare all of write value and read value
      rgm.chnl0_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
      rgm.chnl1_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
      rgm.chnl2_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);

      // send IDLE command
      `uvm_do_on(idle_reg_seq, p_sequencer.reg_sqr)
    endtask
    task do_formatter();
      `uvm_do_on_with(fmt_config_seq, p_sequencer.fmt_sqr, {fifo inside {SHORT_FIFO, ULTRA_FIFO}; bandwidth inside {LOW_WIDTH, ULTRA_WIDTH};})
    endtask
    task do_data();
      fork
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[0], 
          {ntrans inside {[400:600]}; ch_id==0; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32};})
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], 
          {ntrans inside {[400:600]}; ch_id==0; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32};})
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[2], 
          {ntrans inside {[400:600]}; ch_id==0; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32};})
      join
      #10us; // wait until all data haven been transfered through MCDF
    endtask
  endclass: mcdf_full_random_virtual_sequence
  
 //TODO-3.1 Use build-in uvm register sequence
  //  -uvm_reg_hw_reset_seq
  //  -uvm_reg_bit_bash_seq
  //  -uvm_reg_access_seq
  class mcdf_reg_builtin_virtual_sequence extends mcdf_base_virtual_sequence;
    `uvm_object_utils(mcdf_reg_builtin_virtual_sequence)
    function new (string name = "mcdf_reg_builtin_virtual_sequence");
      super.new(name);
    endfunction

    task do_reg();
      uvm_reg_hw_reset_seq reg_rst_seq = new(); 
      uvm_reg_bit_bash_seq reg_bit_bash_seq = new();
      uvm_reg_access_seq reg_acc_seq = new();

      // wait reset asserted and release
      @(negedge p_sequencer.mcdf_vif.rstn);
      @(posedge p_sequencer.mcdf_vif.rstn);

      `uvm_info("BLTINSEQ", "register reset sequence started", UVM_LOW)
      rgm.reset();
      reg_rst_seq.model = rgm;
      reg_rst_seq.start(p_sequencer.reg_sqr);
      `uvm_info("BLTINSEQ", "register reset sequence finished", UVM_LOW)

      `uvm_info("BLTINSEQ", "register bit bash sequence started", UVM_LOW)
      // reset hardware register and register model
      p_sequencer.mcdf_vif.rstn <= 'b0;
      repeat(5) @(posedge p_sequencer.mcdf_vif.clk);
      p_sequencer.mcdf_vif.rstn <= 'b1;
      rgm.reset();
      reg_bit_bash_seq.model = rgm;
      reg_bit_bash_seq.start(p_sequencer.reg_sqr);
      `uvm_info("BLTINSEQ", "register bit bash sequence finished", UVM_LOW)

      `uvm_info("BLTINSEQ", "register access sequence started", UVM_LOW)
      // reset hardware register and register model
      p_sequencer.mcdf_vif.rstn <= 'b0;
      repeat(5) @(posedge p_sequencer.mcdf_vif.clk);
      p_sequencer.mcdf_vif.rstn <= 'b1;
      rgm.reset();
      reg_acc_seq.model = rgm;
      reg_acc_seq.start(p_sequencer.reg_sqr);
      `uvm_info("BLTINSEQ", "register access sequence finished", UVM_LOW)
    endtask
  endclass: mcdf_reg_builtin_virtual_sequence
