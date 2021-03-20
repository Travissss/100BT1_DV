
+incdir+$MCDF_ROOT/env
+incdir+$MCDF_ROOT/vip/chnl_env
+incdir+$MCDF_ROOT/vip/fmt_env
+incdir+$MCDF_ROOT/vip/reg_env
+incdir+$MCDF_ROOT/vip/rgm
+incdir+$MCDF_ROOT/vip/arb_env

//Source file
-f $MCDF_ROOT/../rtl/rtl.f
$MCDF_ROOT/vip/chnl_env/chnl_pkg.sv
$MCDF_ROOT/vip/fmt_env/fmt_pkg.sv
$MCDF_ROOT/vip/reg_env/reg_pkg.sv
$MCDF_ROOT/vip/rgm/mcdf_rgm_pkg.sv
$MCDF_ROOT/vip/arb_env/arb_pkg.sv


$MCDF_ROOT/tb/mcdf_intf.sv
$MCDF_ROOT/env/mcdf_pkg.sv
$MCDF_ROOT/env/mcdf_base_test.sv
$MCDF_ROOT/tb/mcdf_tb.sv
$MCDF_ROOT/seqlib/mcdf_seqlib.sv
$MCDF_ROOT/seqlib/mcdf_vseq.sv
-f $MCDF_ROOT/sim/tc.f
