`timescale 1ns / 1ps
module stream_scr_slv(
    input               rst_n    ,    /*rst_n is necessary to prevet locking up*/
    input               clk      ,      /*clock signal*/
    input               load     ,     /*load seed to rand_num,active high */
    input      [32:0]   seed     ,
    input	            valid,
    output     [32:0]    rand_num  /*random number output*/
);
reg [32:0]    rand_num ;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rand_num    <=0;
    else if(load)
        rand_num <=33'b0;    /*load the initial value when load is active*/
    else if (valid)
        begin
            rand_num[0] <= rand_num[32]^ rand_num[19] ;
            rand_num[1] <= rand_num[0]  ;
            rand_num[2] <= rand_num[1]  ;
            rand_num[3] <= rand_num[2]  ;
            rand_num[4] <= rand_num[3]  ;
            rand_num[5] <= rand_num[4]  ;
            rand_num[6] <= rand_num[5];
            rand_num[7] <= rand_num[6];
            rand_num[8] <= rand_num[7];
            rand_num[9] <= rand_num[8];
            rand_num[10] <= rand_num[9];
            rand_num[11] <= rand_num[10];
            rand_num[12] <= rand_num[11];
            rand_num[13] <= rand_num[12];
            rand_num[14] <= rand_num[13];
            rand_num[15] <= rand_num[14];
            rand_num[16] <= rand_num[15];
            rand_num[17] <= rand_num[16];
            rand_num[18] <= rand_num[17];
            rand_num[19] <= rand_num[18];			
            rand_num[20] <= rand_num[19];
            rand_num[21] <= rand_num[20];
            rand_num[22] <= rand_num[21];
            rand_num[23] <= rand_num[22];
            rand_num[24] <= rand_num[23];			
            rand_num[25] <= rand_num[24];
            rand_num[26] <= rand_num[25];
            rand_num[27] <= rand_num[26];
            rand_num[28] <= rand_num[27];
            rand_num[29] <= rand_num[28];			
            rand_num[30] <= rand_num[29];
            rand_num[31] <= rand_num[30];
            rand_num[32] <= rand_num[31];			
        end
     else    rand_num    <=seed      ;       
end


endmodule