`timescale 1ns / 1ps
module syb_mapping(
    input               rst_n         ,    /*rst_n is necessary to prevet locking up*/
    input               clk           ,      /*clock signal*/
    input      [1:0]    tx_mode       ,
    input               tx_enable     ,  
    input    [2:0]      sdn           ,  
    input               sxn           ,	
	
    output reg [1:0]    TAn           ,
    output reg [1:0]    TBn            	// -1 01, 0 00, +1 11
);

 localparam  SEND_Z         = 0;
 localparam  SEND_I         = 1;
 localparam  SEND_N         = 2; 
// localparam  SEND_N_IDLE    = 3;

always @ (posedge clk or negedge rst_n)
begin 
    if (! rst_n) 
	  begin     
     	  TAn  <= 2'b00;
		  TBn  <= 2'b00; 
	  end
     else if (tx_mode == SEND_Z)
	  begin     
     	  TAn  <= 2'b00;
		  TBn  <= 2'b00; 
	  end 
     else if (tx_mode == SEND_I)  
	  begin 
	     case (sdn)    
     	  3'b000: begin TAn  <= 2'b01;  TBn  <= 2'b00; end
		  3'b001: begin TAn  <= 2'b00;  TBn  <= 2'b11; end
		  3'b010: begin TAn  <= 2'b01;  TBn  <= 2'b11; end
		  3'b011: begin TAn  <= 2'b00;  TBn  <= 2'b11; end
     	  3'b100: begin TAn  <= 2'b11;  TBn  <= 2'b00; end
		  3'b101: begin TAn  <= 2'b00;  TBn  <= 2'b01; end
		  3'b110: begin TAn  <= 2'b11;  TBn  <= 2'b01; end
		  3'b111: begin TAn  <= 2'b00;  TBn  <= 2'b01; end
          endcase		  
	  end
     // else if ((tx_mode == SEND_N) & (tx_enable) )  
	  // begin 
	     // case (sdn)    
     	  // 3'b000: begin TAn  <= 2'b01;  TBn  <= 2'b01; end
		  // 3'b001: begin TAn  <= 2'b01;  TBn  <= 2'b00; end
		  // 3'b010: begin TAn  <= 2'b01;  TBn  <= 2'b11; end
		  // 3'b011: begin TAn  <= 2'b00;  TBn  <= 2'b01; end
     	  // 3'b100: begin TAn  <= 2'b00;  TBn  <= 2'b11; end
		  // 3'b101: begin TAn  <= 2'b11;  TBn  <= 2'b01; end
		  // 3'b110: begin TAn  <= 2'b11;  TBn  <= 2'b00; end
		  // 3'b111: begin TAn  <= 2'b11;  TBn  <= 2'b11; end
          // endcase		  
	  // end
     else if ((tx_mode == SEND_N) & (~tx_enable)&(~sxn) )  
	  begin 
	     case (sdn)    
     	  3'b000: begin TAn  <= 2'b01;  TBn  <= 2'b00; end
		  3'b001: begin TAn  <= 2'b00;  TBn  <= 2'b11; end
		  3'b010: begin TAn  <= 2'b01;  TBn  <= 2'b11; end
		  3'b011: begin TAn  <= 2'b00;  TBn  <= 2'b11; end
     	  3'b100: begin TAn  <= 2'b11;  TBn  <= 2'b00; end
		  3'b101: begin TAn  <= 2'b00;  TBn  <= 2'b01; end
		  3'b110: begin TAn  <= 2'b11;  TBn  <= 2'b01; end
		  3'b111: begin TAn  <= 2'b00;  TBn  <= 2'b01; end
          endcase		  
	  end			 
     else if ((tx_mode == SEND_N) & (~tx_enable)&(sxn) )  
	  begin 
	     case (sdn)    
     	  3'b000: begin TAn  <= 2'b01;  TBn  <= 2'b00; end
		  3'b001: begin TAn  <= 2'b11;  TBn  <= 2'b11; end
		  3'b010: begin TAn  <= 2'b01;  TBn  <= 2'b11; end
		  3'b011: begin TAn  <= 2'b11;  TBn  <= 2'b11; end
     	  3'b100: begin TAn  <= 2'b11;  TBn  <= 2'b00; end
		  3'b101: begin TAn  <= 2'b01;  TBn  <= 2'b01; end
		  3'b110: begin TAn  <= 2'b11;  TBn  <= 2'b01; end
		  3'b111: begin TAn  <= 2'b01;  TBn  <= 2'b01; end
          endcase		  
	  end	  
	  else	 
   	  begin     
     	  TAn  <= 2'b00;
		  TBn  <= 2'b00; 
	  end
			 
end






endmodule