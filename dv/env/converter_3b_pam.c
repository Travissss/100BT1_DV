#include <svdpi.h> 

void converter_3b_pam(
	//input
	//const svBitVecVal* 	scr_data	,
    int  scr_data0	,
    int  scr_data1	,
    int  scr_data2	,
	const svBitVecVal* 	tx_mode		,
	const svBitVecVal* 	loop_num,
	svBit 				master_slave,		
	//output
		
	svBitVecVal* 	TAn_o			,	
	svBitVecVal* 	TBn_o
	){		
	int seed[33] = {1,0,1,1,0,0,0,0,0,0,0,0,1,0,1,1,1,1,0,1,0,0,0,0,1,0,1,0,1,0,0,0,0};	
	int temp;
	int TAn;
	int TBn;
	

	//scr
	int syn[3]; 
	int scn[3];
	int sxn;
	int sdn[3];
	int i, j;
	int loop_i;
	loop_i = *loop_num;
	for(i = 0; i < loop_i; i++){
		for(j = 1; j <= 31; j++){
			temp = seed[0];
			seed[0] = seed[32]^seed[12]; 
			seed[j+1] = seed[j];
			seed[1] = temp;
		}	
	}
	sxn = seed[7]^seed[9]^seed[12]^seed[14];
	syn[0] = seed[0];
	syn[1] = seed[3]^seed[8];
	syn[2] = seed[6]^seed[16];

	scn[0] = (*tx_mode == 0)? 0: syn[0];
	scn[1] = (*tx_mode == 0)? 0: syn[1];
	scn[2] = (*tx_mode == 0)? 0: syn[2];

	sdn[2] = (scn[2]^scr_data2);// : (master_slave ? (~scn[2]):scn[2]);
	sdn[1] = (scn[1]^scr_data1);// : scn[1];
	sdn[0] = (scn[0]^scr_data0);// : scn[0]; 
		
	if (*tx_mode == 0){
     	  TAn = 0;
		  TBn = 0; 
	}
     else if (*tx_mode == 1){  
	    if( sdn[0]==0 && sdn[1]==0 && sdn[2]==0){
			TAn  = 1;  TBn  = 0;
		}else if( sdn[0]==1 && sdn[1]==0 && sdn[2]==0){
			TAn  = 0;  TBn  = 3;
		}else if( sdn[0]==0 && sdn[1]==1 && sdn[2]==0){
			TAn  = 1;  TBn  = 3;
		}else if( sdn[0]==1 && sdn[1]==1 && sdn[2]==0){
			TAn  = 0;  TBn  = 3;
		}else if( sdn[0]==0 && sdn[1]==0 && sdn[2]==1){
			TAn  = 3;  TBn  = 0;
		}else if( sdn[0]==1 && sdn[1]==0 && sdn[2]==1){
			TAn  = 0;  TBn  = 1;
		}else if( sdn[0]==0 && sdn[1]==1 && sdn[2]==1){
			TAn  = 3;  TBn  = 1;
		}else if( sdn[0]==1 && sdn[1]==1 && sdn[2]==1){
			TAn  = 0;  TBn  = 1;
		}

	}else if ((*tx_mode == 2) && (!sxn) ) { 
		 if( sdn[0]==0 && sdn[1]==0 && sdn[2]==0){
			TAn  = 1;  TBn  = 0;
		}else if( sdn[0]==1 && sdn[1]==0 && sdn[2]==0){
			TAn  = 0;  TBn  = 3;
		}else if( sdn[0]==0 && sdn[1]==1 && sdn[2]==0){
			TAn  = 1;  TBn  = 3;
		}else if( sdn[0]==1 && sdn[1]==1 && sdn[2]==0){
			TAn  = 0;  TBn  = 3;
		}else if( sdn[0]==0 && sdn[1]==0 && sdn[2]==1){
			TAn  = 3;  TBn  = 0;
		}else if( sdn[0]==1 && sdn[1]==0 && sdn[2]==1){
			TAn  = 0;  TBn  = 1;
		}else if( sdn[0]==0 && sdn[1]==1 && sdn[2]==1){
			TAn  = 3;  TBn  = 1;
		}else if( sdn[0]==1 && sdn[1]==1 && sdn[2]==1){
			TAn  = 0;  TBn  = 1;
		}
	}else if ((*tx_mode == 2) && (sxn) )  {
	  if( sdn[0]==0 && sdn[1]==0 && sdn[2]==0){
			TAn  = 1;  TBn  = 0;
		}else if( sdn[0]==1 && sdn[1]==0 && sdn[2]==0){
			TAn  = 3;  TBn  = 3;
		}else if( sdn[0]==0 && sdn[1]==1 && sdn[2]==0){
			TAn  = 1;  TBn  = 3;
		}else if( sdn[0]==1 && sdn[1]==1 && sdn[2]==0){
			TAn  = 3;  TBn  = 3;
		}else if( sdn[0]==0 && sdn[1]==0 && sdn[2]==1){
			TAn  = 3;  TBn  = 0;
		}else if( sdn[0]==1 && sdn[1]==0 && sdn[2]==1){
			TAn  = 1;  TBn  = 1;
		}else if( sdn[0]==0 && sdn[1]==1 && sdn[2]==1){
			TAn  = 3;  TBn  = 1;
		}else if( sdn[0]==1 && sdn[1]==1 && sdn[2]==1){
			TAn  = 1;  TBn  = 1;
		}
	}else {	  
     	  TAn  = 0;
		  TBn  = 0; 
		}
	

     	  *TAn_o  = TAn;
		  *TBn_o  = TBn; 
	
	}
