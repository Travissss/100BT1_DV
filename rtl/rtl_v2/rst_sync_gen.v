`timescale 1ns / 1ps
module rst_sync_gen (

input   sys_clk_33m,
input   sys_clk_25m,
input   reset_n,

output  rst_n_25m,   
output  rst_n_33m

);

reg     rst_n_25m_r0;
reg     rst_n_25m_r1;
reg     rst_n_33m_r0;
reg     rst_n_33m_r1;

 
always @ (posedge sys_clk_25m or negedge reset_n)  
begin
     if (!reset_n) begin   
                         rst_n_25m_r0 <= 1'b0;  
                         rst_n_25m_r1 <= 1'b0;  
                       end  
     else   begin  
                 rst_n_25m_r0 <= 1'b1;  
                 rst_n_25m_r1 <= rst_n_25m_r0;  
            end  
end

always @ (posedge sys_clk_33m or negedge reset_n)  
begin
     if (!reset_n) begin   
                         rst_n_33m_r0 <= 1'b0;  
                         rst_n_33m_r1 <= 1'b0;  
                       end  
     else   begin  
                 rst_n_33m_r0 <= 1'b1;  
                 rst_n_33m_r1 <= rst_n_33m_r0;  
            end  
end

assign rst_n_25m = rst_n_25m_r1;
assign rst_n_33m = rst_n_33m_r1;
 
endmodule  