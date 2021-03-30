module scr_data_gen (

  input        rst_n          ,
  input        clk            ,
  input  [2:0] tx_data        ,
  input  [1:0] tx_mode        , 
  input        master_slave_sw      ,
  input        load           ,
  input       valid          ,
  input [32:0] seed           ,
  input        loc_rcvr_status,
  input        tx_enable      , // which should be ahead of tx_data 3 clks
  
  output         sxn        ,
  output [2:0]   sdn        
  
  
  );
 localparam  SEND_Z         = 0;
 localparam  SEND_I         = 1;
 localparam  SEND_N         = 2; 
 localparam  SEND_N_IDLE    = 3;
 
(* MARK_DEBUG="True" *) wire  [32:0]   scrn   ; 
 wire  [32:0]   scrn_mar   ;
 wire  [32:0]   scrn_slv   ; 
 wire  [2:0]    syn    ; 
 wire  [2:0]    scn    ;


 
 stream_scrambler stream_scrambler(
   /* input             */   .rst_n   (rst_n   ) ,    /*rst_n is necessary to prevet locking up*/
   /* input             */   .clk     (clk     ) ,      /*clock signal*/
   /* input             */   .load    (load    ) ,     /*load seed to rand_num,active high */
   /* input      [32:0] */   .seed    (seed    ) ,
   /* input	            */   .valid   (valid   ) ,
   /* output     [32:0] */   .rand_num(scrn_mar  )  /*random number output*/
);

 stream_scr_slv stream_scr_slv(
   /* input             */   .rst_n   (rst_n   ) ,    /*rst_n is necessary to prevet locking up*/
   /* input             */   .clk     (clk     ) ,      /*clock signal*/
   /* input             */   .load    (load    ) ,     /*load seed to rand_num,active high */
   /* input      [32:0] */   .seed    (seed    ) ,
   /* input	            */   .valid   (valid   ) ,
   /* output     [32:0] */   .rand_num(scrn_slv  )  /*random number output*/
); 

 assign scrn = master_slave_sw ? scrn_slv:scrn_mar;
 assign sxn = scrn[7]^scrn[9]^scrn[12]^scrn[14];
 
 assign syn[0] = scrn[0];
 assign syn[1] = scrn[3]^scrn[8];
 assign syn[2] = scrn[6]^scrn[16];
 
 assign scn = (tx_mode == SEND_Z)? 3'b0: syn;
 
 assign sdn[2]   = tx_enable? (scn[2]^tx_data[2]):(loc_rcvr_status? (~scn[2]):scn[2]);
 assign sdn[1]  = tx_enable? (scn[1]^tx_data[1]) : scn[1];
 assign sdn[0]  = tx_enable? (scn[0]^tx_data[0]) : scn[0]; 
 

endmodule