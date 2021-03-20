//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		Travis
// 
// Create Date: 	03/04/2021 Thu 21:10
// Filename: 		mcdf_pkg.sv
// class Name: 		mcdf_pkg
// Project Name: 	mcdf
// Revision 0.01 - File Created 
// Additional Comments:
// -------------------------------------------------------------------------------
// 	-> Top test package
//////////////////////////////////////////////////////////////////////////////////

`include "param_def.v"

package mcdf_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import chnl_pkg::*;
import reg_pkg::*;
import arb_pkg::*;
import fmt_pkg::*;
import mcdf_rgm_pkg::*;

typedef struct packed{
    bit [2:0]   len;
    bit [1:0]   prio;
    bit         en;
    bit [7:0]   avail;
} mcdf_reg_t;

typedef enum {RW_LEN, RW_PRIO, RW_EN, RD_AVAIL} mcdf_field_t;

`include "mcdf_cov.sv"
`include "mcdf_refmod.sv"

`include "mcdf_scb.sv"
`include "mcdf_vsqr.sv"
`include "mcdf_env.sv"

endpackage
