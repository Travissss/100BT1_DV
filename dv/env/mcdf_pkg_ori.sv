




`include "param_def.v"

package mcdf_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import chnl_pkg::*;
  import reg_pkg::*;
  import arb_pkg::*;
  import fmt_pkg::*;
  import mcdf_rgm_pkg::*;

  typedef struct packed {
    bit[2:0] len;
    bit[1:0] prio;
    bit en;
    bit[7:0] avail;
  } mcdf_reg_t;

  typedef enum {RW_LEN, RW_PRIO, RW_EN, RD_AVAIL} mcdf_field_t;


`include "mcdf_refmod.sv"
  // MCDF checker (scoreboard)
`include "mcdf_scb.sv"

  // MCDF coverage model
`include "mcdf_cov.sv"

`include "mcdf_vsqr.sv"
`include "mcdf_env.sv"


  

endpackage
