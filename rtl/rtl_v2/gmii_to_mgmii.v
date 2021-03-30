// **********************************************************************//
// Module	: mii_gmii_wrapper				         //
// Function	: Data conversion between MII and GMII interface         //
// Project	: Pearl                                                  //
// **********************************************************************//
module gmii_to_mgmii (
      // Outputs
        txd_out,
        txen_out,
        txer_out,
      // Inputs
        clk_gmii_2x,
        mac_clk_tx,
        resetn_tx,
        gmii_mode,
        txd_in,
        txen_in
    ) /* synthesis syn_sharing=off */;
output [7:0] txd_out;//sw to dk
output       txen_out;//sw to dk
output	     txer_out;

input        clk_gmii_2x;
input        gmii_mode;
input        mac_clk_tx;
input        resetn_tx;

input [7:0]  txd_in;//sw to dk
input        txen_in;//sw to dk

/////////////////////////////////////////

wire       clk_tx;
wire [7:0] txd_out;
wire       txen_out;

/////////////////////////////////////////

wire sb_clk_tx;
reg resetn_q_tx, resetn_sbclk_tx;

/////////////////////////////////////////

assign sb_clk_tx = clk_gmii_2x; //gmii_mode ? mac_clk_tx : clk_gmii_2x; 
assign txer_out =  1'b0;

// synchronize resetn to sb_clk
always @(posedge sb_clk_tx or negedge resetn_tx)
  if (~resetn_tx) begin
    resetn_q_tx     <= 1'b0;
    resetn_sbclk_tx <= 1'b0;
  end
  else begin
    resetn_q_tx     <= 1'b1;
    resetn_sbclk_tx <= resetn_q_tx;
  end

//ddio_out px_tck (.aclr(1'b0), .datain_h(1'b1), .datain_l(1'b0), .outclock(sb_clk_tx), .dataout(clk_tx));
assign clk_tx = sb_clk_tx;

/////////////////////////////////
// tx 8-bit to 4-bit
/////////////////////////////////
// fifo write logic 
reg [1:0] twadr, twadr_gray;
reg [7:0] tmem[3:0];

wire [1:0] twadr_d;

wire tfifo_wr = gmii_mode ? 1'b0 : txen_in;
assign twadr_d = tfifo_wr ? (twadr + 1'b1) : twadr;

always @(posedge mac_clk_tx or negedge resetn_tx)
  if (~resetn_tx)
  begin
    twadr        <= 2'h0;
    twadr_gray   <= 2'h0;
  end
  else
  begin
    twadr        <= twadr_d;
    twadr_gray   <= ({1'b0, twadr_d[1]} ^ twadr_d);
  end

always @(posedge mac_clk_tx)
  if (tfifo_wr)
    tmem[twadr] <= txd_in;

/////////////////////////////////
// fifo read logic 
reg [1:0] tradr;
reg [7:0] twadr_sync;
reg [7:0] dout;
reg [1:0] tfifo_rd_del;
reg       txen_out_d;
reg       tfifo_rd;

wire       tfifo_empty;
wire [1:0] twadr_2q_bin;
wire [1:0] tradr_d;

// by design this fifo should never go full
assign tfifo_empty = (tradr == twadr_2q_bin);
assign tradr_d = tfifo_rd ? (tradr + 1'b1) : tradr;

always @(posedge sb_clk_tx or negedge resetn_sbclk_tx)
  if(~resetn_sbclk_tx)
  begin
    tradr      <= 2'h0;
    tfifo_rd   <= 1'b0;
    twadr_sync <= 7'h0;
  end
  else 
  begin
    tradr      <= tradr_d;
    tfifo_rd   <= tfifo_empty ? 1'b0 : ~tfifo_rd;
    twadr_sync <= { twadr_sync[5:0], twadr_gray[1:0] };
  end

assign twadr_2q_bin = (twadr_sync[7:6] == 2'h3) ? 2'h2 : 
                      (twadr_sync[7:6] == 2'h2) ? 2'h3 : twadr_sync[7:6];

always @(posedge sb_clk_tx or negedge resetn_sbclk_tx)
  if (~resetn_sbclk_tx)
    tfifo_rd_del<= 2'h0;
  else
    tfifo_rd_del<= { tfifo_rd_del[0], tfifo_rd };

always @(posedge sb_clk_tx)
  if (tfifo_rd)
    dout <= tmem[tradr];

assign txd_out = (tfifo_rd_del[1:0] == 2'h1) ? {dout[3:0], dout[3:0]} : 
                                     (tfifo_rd_del[1:0] == 2'h2) ? {dout[7:4], dout[7:4]} : 8'h0;
assign txen_out = |tfifo_rd_del[1:0];

endmodule

