module cov_4B3B_0 (
input           sys_clk_25m   ,
input           rst_n_25m     ,
input           sys_clk_33m   ,
input           rst_n_33m     ,
input     [3:0] TXD           ,
input           tx_enable_mii ,
output reg[2:0] tx_data       ,
output reg      tx_data_en
);

 localparam  TX_IDLE        = 0;
 localparam  TX_DATA0       = 1;
 localparam  TX_DATA1       = 2; 
 localparam  TX_DATA2       = 3;
 localparam  TX_DATA3       = 4;
 localparam  TX_DATA4       = 5; 
 localparam  TX_DATA5       = 6;
 localparam  TX_DATA6       = 7;
 localparam  TX_DATA7       = 8; 

reg [3:0] state    ; 
reg [2:0] store_cnt;
reg       tx_enable_mii_r0;
reg       tx_enable_mii_r1;
reg       tx_mii_en       ;
reg       tx_en_in0       ;
reg [4:0] d0;
reg [4:0] d1;
reg [4:0] d2;
reg [4:0] d3;
reg [4:0] d4;
reg [4:0] d5;
 always@ (posedge sys_clk_25m or negedge rst_n_25m)
 begin if (!rst_n_25m) store_cnt <= 0     ;
       else  if (store_cnt==5) store_cnt <= 0;
	   else  if (tx_enable_mii)        store_cnt <= store_cnt+1;
 end
 
always @(posedge sys_clk_25m or negedge rst_n_25m)
begin
    if(!rst_n_25m)        
               begin 	
			       d0 <= 5'b0;
			       d1 <= 5'b0;
			       d2 <= 5'b0;
			       d3 <= 5'b0;
			       d4 <= 5'b0;
			       d5 <= 5'b0;
			   end
	else if (store_cnt == 0 ) d0 <= {tx_enable_mii,TXD};
	else if (store_cnt == 1 ) d1 <= {tx_enable_mii,TXD};
	else if (store_cnt == 2 ) d2 <= {tx_enable_mii,TXD};
	else if (store_cnt == 3 ) d3 <= {tx_enable_mii,TXD};	
	else if (store_cnt == 4 ) d4 <= {tx_enable_mii,TXD};
	else if (store_cnt == 5 ) d5 <= {tx_enable_mii,TXD};
end	

always @(posedge sys_clk_33m or negedge rst_n_33m)
begin
    if(!rst_n_33m)        
               begin 	
                  tx_enable_mii_r0 <= 0;
                  tx_enable_mii_r1 <= 0;                  
                  tx_mii_en        <= 0;
			   end
     else
               begin 	
                  tx_enable_mii_r0 <= tx_enable_mii;
                  tx_enable_mii_r1 <= tx_enable_mii_r0;                  
                  tx_mii_en        <= tx_enable_mii_r1;
			   end	 
 end

 
always @(posedge sys_clk_33m or negedge rst_n_33m)
begin
    if(!rst_n_33m)   
    begin  
	  state  <= TX_IDLE;
	  tx_data<= 3'b0   ;
	  tx_data_en <=0   ;
//	  tx_en_in0  <=0   ;
	end
    else
    begin
        case(state)
            TX_IDLE:   
			   begin 
			   tx_data   <=0;
			   tx_data_en<=0;
			     if (tx_mii_en) 
				   begin
				   state <= TX_DATA0;
//				   tx_en_in0=1'b1   ;
				   end
				 else 
				   state <= TX_IDLE;
			   end
            TX_DATA0:   
			   begin 
			   tx_data   <=d0[2:0];
			   tx_data_en<=1'b1;
			     if (d0[4]) 
				   begin
				   state <= TX_DATA1;
				   end
				 else 
				   state <= TX_IDLE;
			   end	  
            TX_DATA1:   
			   begin 
			   tx_data   <={d1[1:0],d0[3]};
			   tx_data_en<=1'b1;
			     if (d1[4]) 
				   begin
				   state <= TX_DATA2;
				   end
				 else 
				   state <= TX_IDLE;
			   end
            TX_DATA2:   
			   begin 
			   tx_data   <={d2[0],d1[3:2]};
			   tx_data_en<=1'b1;
			     if (d2[4]) 
				   begin
				   state <= TX_DATA3;
				   end
				 else 
				   state <= TX_IDLE;
			   end	
            TX_DATA3:   
			   begin 
			   tx_data   <= d2[3:1] ;
			   tx_data_en<=1'b1;
			     if (d3[4]) 
				   begin
				   state <= TX_DATA4;
				   end
				 else 
				   state <= TX_IDLE;
			   end	
            TX_DATA4:   
			   begin 
			   tx_data   <= d3[2:0] ;
			   tx_data_en<=1'b1;
			     if (d3[4]) 
				   begin
				   state <= TX_DATA5;
				   end
				 else 
				   state <= TX_IDLE;
			   end	
            TX_DATA5:   
			   begin 
			   tx_data   <= {d4[1:0],d3[3]} ;
			   tx_data_en<=1'b1;
			     if ( d4[4]) 
				   begin
				   state <= TX_DATA6;
				   end
				 else 
				   state <= TX_IDLE;
			   end
            TX_DATA6:   
			   begin 
			   tx_data   <= {d5[0],d4[3:2]} ;
			   tx_data_en<=1'b1;
			     if (d5[4]) 
				   begin
				   state <= TX_DATA7;
				   end
				 else 
				   state <= TX_IDLE;
			   end
            TX_DATA7:   
			   begin 
			   tx_data   <= d5[3:1];
			   tx_data_en<=1'b1;
			     if (d0[4]) 
				   begin
				   state <= TX_DATA0;
				   tx_en_in0 <= 0 ;
				   end
				 else 
				   state <= TX_IDLE;
			   end
             default:
			     begin  
	              state  <= TX_IDLE;
	              tx_data<= 3'b0   ;
	              tx_data_en <=0   ;
	              tx_en_in0  <=0   ;
	             end			   
        endcase
    end
end
endmodule










