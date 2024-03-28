`include "ddr3_controller.vh"

module efx_ddr3_axi
(
input axi_clk,
input core_clk,
input twd_clk,
input tdqss_clk,
input tac_clk,
input nrst,

output reset,
output cs,
output ras,
output cas,
output we,
output cke,
output [15:0]addr,
output [2:0]ba,
output odt,
output [`DRAM_GROUP-1'b1:0] o_dm_hi,
output [`DRAM_GROUP-1'b1:0] o_dm_lo,

input [`DRAM_GROUP-1'b1:0]i_dqs_hi,
input [`DRAM_GROUP-1'b1:0]i_dqs_lo,

input [`DRAM_GROUP-1'b1:0]i_dqs_n_hi,
input [`DRAM_GROUP-1'b1:0]i_dqs_n_lo,


output [`DRAM_GROUP-1'b1:0]o_dqs_hi,
output [`DRAM_GROUP-1'b1:0]o_dqs_lo,

output [`DRAM_GROUP-1'b1:0]o_dqs_n_hi,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_lo,


output [`DRAM_GROUP-1'b1:0]o_dqs_oe,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_oe,

input [`DRAM_WIDTH-1'b1:0] i_dq_hi,
input [`DRAM_WIDTH-1'b1:0] i_dq_lo,

output [`DRAM_WIDTH-1'b1:0] o_dq_hi,
output [`DRAM_WIDTH-1'b1:0] o_dq_lo,

output [`DRAM_WIDTH-1'b1:0] o_dq_oe,

input [31:0]			i_aaddr,
input [1:0] 			i_aburst,
input [7:0] 			i_aid,
input [7:0] 			i_alen,
input [1:0] 			i_alock,
output 					o_aready,
input [2:0] 			i_asize,
input					i_atype,
input 					i_avalid,

input [`WFIFO_WIDTH-1:0] i_wdata,
input [7:0] 			i_wid,
input 					i_wlast,
output 					o_wready,
input [15:0]			i_strb,
input 					i_wvalid,

output [7:0] 			o_bid,
input 					i_bready,
output 					o_bvalid,
output [1:0]			o_bresp,

output [`WFIFO_WIDTH-1:0]o_rdata,
output [7:0] 			o_rid,
output 					o_rlast,
input 					i_rready,
output [1:0]			o_rresp,
output 					o_rvalid,

output [2:0]			shift,
output [4:0]			shift_sel,
output 					shift_ena,

input 					cal_ena,
output 		wire		cal_done,
output 					cal_pass,

output 						    debug_wr_busy,
output [`WFIFO_WIDTH-1'b1:0]	debug_wr_data,
output [`DM_BIT_WIDTH-1'b1:0]   debug_wr_datamask,
output [31:0]				    debug_wr_addr,
output 						    debug_wr_en,
output						    debug_wr_addr_en,
output 						    debug_wr_ack,

output 						    debug_rd_busy,
output  [31:0] 				    debug_rd_addr,
output  						debug_rd_addr_en,
output  						debug_rd_en,
output [`WFIFO_WIDTH-1'b1:0]	debug_rd_data,
output 						    debug_rd_valid,
output 						    debug_rd_ack



);

wire [31:0]	w_i_wr_addr;
wire 		w_i_wr_en;
wire 		w_i_awvalid;
reg 		r_i_awvalid;
wire[31:0] 	w_i_rd_addr;
wire 		w_i_rd_en;
wire 		w_i_arvalid;
wire        w_o_rd_ack;
wire [`WFIFO_WIDTH-1'b1:0]w_i_wr_data;
wire [`DM_BIT_WIDTH-1'b1:0]w_i_wr_datamask;
wire [`WFIFO_WIDTH-1'b1:0]w_o_rd_data;
wire w_o_rd_valid;
wire w_o_wr_ack;
wire w_o_wr_busy;
wire w_o_rd_busy;
wire w_awready;
wire w_arready;
wire w_fifo_bvalid;

reg [7:0]r_rd_alen;
wire [7:0]w_awlen_fifo;
wire [7:0]w_arlen_fifo;
wire [7:0]w_blen_fifo;
wire w_wr_b_done;
reg [8:0]r_wr_b_count;

reg [31:0]	r_i_wr_addr;
reg [31:0]	r_i_rd_addr;
reg [31:0]	r_i_rd_addr_p;

assign w_wr_b_done = ((9'b1+w_blen_fifo) == r_wr_b_count)?1'b1:1'b0;

reg [`WFIFO_WIDTH-1'b1:0]r_i_wr_data;

reg r_i_wr_en;
reg r_rlast;

reg [15:0]r_rlast_cnt;

reg [15:0]r_arvalid_cnt;
reg [15:0]r_arvalid_cnt_p;
reg [15:0]r_awvalid_cnt;
reg r_i_wr_addr_en;
reg r_i_rd_addr_en;
reg [15:0]r_i_wr_datamask;
wire [7:0] w_i_awid;
wire [7:0] w_i_arid;

reg [1:0] r_rd_i_aburst;
reg [1:0] r_wr_i_aburst;
reg r_wready;

wire [31:0] w_wr_addr_fifo;
wire [31:0] w_rd_addr_fifo;

wire [1:0]w_i_awburst;
wire [1:0]w_i_arburst;
wire [1:0]w_i_awburst_fifo;
wire [1:0]w_i_arburst_fifo;

wire [7:0] w_i_arlen;
wire [7:0] w_i_awlen;

wire [7:0]w_arlen_rlast_fifo;
reg [7:0]r_arlen_rlast_fifo;

wire w_rd_addr_empty;
wire w_wr_addr_empty;

reg [15:0]r_aw_valid_cnt;
reg r_aw_valid_flag;

wire w_ar_full;
wire w_aw_full;

assign w_i_wr_addr 	= i_atype ? {4'b0,i_aaddr[31:4]} : 32'b0;
assign w_i_rd_addr 	= i_atype ? 32'b0	: {4'b0,i_aaddr[31:4]};
assign w_i_awburst 	= i_atype ? i_aburst : 32'b0;
assign w_i_arburst 	= i_atype ? 32'b0	: i_aburst;
assign w_i_awlen = i_atype ? i_alen : 8'b0;
assign w_i_arlen = i_atype ? 8'b0 : i_alen;

assign o_aready		= cal_done ? (((~w_o_wr_busy)&&(~w_aw_full))&&((~w_o_rd_busy)&&(~w_ar_full))) : 1'b0;

assign w_i_awvalid = i_atype ? i_avalid:1'b0;
assign w_i_arvalid = i_atype ? 1'b0:i_avalid;

assign w_i_awid = i_atype ? i_aid:1'b0;
assign w_i_arid = i_atype ? 1'b0:i_aid;

assign w_i_wr_data 		= i_wdata;
assign w_i_wr_datamask 	= (~i_strb);
assign o_wready			= cal_done ? ((~w_o_wr_busy) && (~w_i_awvalid) && (~r_i_awvalid) && (r_aw_valid_flag)):1'b0;
assign w_i_wr_en		= i_wvalid;

assign o_rdata =  w_o_rd_data;
assign w_i_rd_en = i_rready;
assign o_rlast =  ((r_rlast_cnt == r_arlen_rlast_fifo)?(o_rvalid):0);
assign o_rvalid = cal_done ? w_o_rd_valid : 1'b0;

assign o_rresp = 2'b00;
assign o_bresp = 2'b00;

assign o_bvalid = ~w_fifo_bvalid;



assign w_awready = o_aready;
assign w_arready = o_aready;

wire w_awaddr_fifo_rd_en;
wire w_sample_aw_fifo;

reg [15:0]r_wr_cnt;
assign w_sample_aw_fifo = (r_wr_cnt == (w_awlen_fifo))?1'b1:1'b0;
reg r_awaddr_fifo_rd_en;
assign w_awaddr_fifo_rd_en = (i_wlast&&i_wvalid&&o_wready);



reg r_ar_sample;

reg r_ar_sample_rd_en;

reg [3:0]r_ar_state;

reg [1:0]r_empty;

reg r_i_wvalid;

wire w_empty_rise;
reg r_empty_rise;
assign w_empty_rise = (~w_wr_addr_empty) &&(r_empty[0]);

wire [49:0]w_fifo_aw;

assign w_wr_addr_fifo 	= w_fifo_aw[31:0];
assign w_awlen_fifo 	= w_fifo_aw[39:32];
assign w_i_awburst_fifo = w_fifo_aw[41:40];


localparam AR_SAMPLE_IDEL	=0;
localparam AR_SAMPLE_ST0	=1;
localparam AR_SAMPLE_ST1	=2;
localparam AR_SAMPLE_ST2	=3;
localparam AR_SAMPLE_ST3	=4;


always @(posedge axi_clk or negedge cal_done)
begin
	if(~cal_done)
	begin
		r_rlast_cnt			<= 16'b0;
		
		r_i_wr_addr			<= 32'b0;		
		
		r_i_rd_addr			<= 32'b0;
		r_i_rd_addr_p		<= 32'b0;
		
		r_i_wr_addr_en		<= 1'b0;
		r_i_rd_addr_en		<= 1'b0;
		r_i_wr_data			<= 128'b0;		
		r_i_wr_en			<= 1'b0;
		
		r_arvalid_cnt		<= 16'b0;
		
		r_i_wr_datamask		<= 16'b0;		
				
		r_rd_alen			<= 8'b0;		
        
        r_wr_i_aburst       <= 2'd0;
        r_rd_i_aburst       <= 2'd0;
				
		r_wr_b_count		<= 9'd0;		
				
		r_ar_sample			<=1'b0;
		r_ar_state			<=AR_SAMPLE_IDEL;
		
		r_ar_sample_rd_en	<=1'b0;
		r_wready			<=1'b0;
		r_empty				<=2'b11;
		r_i_wvalid			<=1'b0;
		r_awaddr_fifo_rd_en	<=1'b0;		
		r_empty_rise		<=1'b0;
		r_wr_cnt			<=16'b0;
		r_i_awvalid			<=1'b0;		
		r_arlen_rlast_fifo	<=8'b0;
		r_aw_valid_cnt		<=16'b0;
		r_aw_valid_flag		<=1'b0;
        
	end
	else
	begin
		r_i_rd_addr_en		<= 1'b0;
		r_i_wr_en			<= 1'b0;		
					
		r_ar_sample			<=~w_rd_addr_empty;		
		r_ar_sample_rd_en	<= 1'b0;		
		r_wready			<= o_wready;
		r_i_wvalid			<=i_wvalid;
		
		r_empty[0]			<=w_wr_addr_empty;
		r_empty[1]			<=r_empty[0];
		r_empty_rise		<=w_empty_rise;
		
		r_awaddr_fifo_rd_en	<=w_awaddr_fifo_rd_en;		
		r_i_awvalid			<=w_i_awvalid;		
		r_arlen_rlast_fifo	<=w_arlen_rlast_fifo;		
		r_aw_valid_flag		<=1'b0;
		
		if(w_awaddr_fifo_rd_en)
		begin
			r_aw_valid_cnt <= r_aw_valid_cnt -1'b1;
			
			if(w_i_awvalid  && w_awready)
				r_aw_valid_cnt <= r_aw_valid_cnt;
		end
		else
		begin
			if(w_i_awvalid  && w_awready)
				r_aw_valid_cnt <= r_aw_valid_cnt +1'b1;
		end
		
		if(r_aw_valid_cnt != 16'b0)
			r_aw_valid_flag	<=1'b1;
		
		if(r_ar_sample && (r_ar_state==AR_SAMPLE_IDEL))
		begin
			r_ar_state	<=AR_SAMPLE_ST0;
		end
				
		if(r_ar_state==AR_SAMPLE_ST0)
		begin
			r_i_rd_addr		<=w_rd_addr_fifo;
			r_i_rd_addr_p	<=w_rd_addr_fifo;
			r_rd_alen		<=w_arlen_fifo;
			r_rd_i_aburst   <=w_i_arburst_fifo;
			r_ar_state		<=AR_SAMPLE_ST1;
			r_arvalid_cnt	<=w_arlen_fifo;
			r_arvalid_cnt_p <=w_arlen_fifo;			
		end
		else if(r_ar_state==AR_SAMPLE_ST1)
		begin
			if(~w_o_rd_busy)
			begin
				if(r_rd_i_aburst == 2'b01)			
					r_i_rd_addr		<= r_i_rd_addr + 1'b1;			
				else			
					r_i_rd_addr		<= r_i_rd_addr;			
				
				r_i_rd_addr_en	<=1'b1;
				r_arvalid_cnt	<=r_arvalid_cnt-1'b1;
				r_arvalid_cnt_p	<=r_arvalid_cnt;
				r_i_rd_addr_p	<=r_i_rd_addr;
							
				if((r_arvalid_cnt_p)==(16'b0))
				begin
					r_ar_state			<=AR_SAMPLE_ST2;
					r_ar_sample_rd_en	<=1'b1;
					
					if(r_rd_alen != 8'b0)
					begin
						r_i_rd_addr_en		<=1'b0;
						r_i_rd_addr_p		<=32'b0;
					end
				end
			end
		end
		else if(r_ar_state==AR_SAMPLE_ST2)
		begin
			r_ar_state			<=AR_SAMPLE_ST3;
		end
		else if(r_ar_state==AR_SAMPLE_ST3)
		begin
			r_ar_state			<=AR_SAMPLE_IDEL;
		end
		
		if(r_i_wvalid && r_wready)
		begin
			if(r_wr_i_aburst == 2'b01)
				r_i_wr_addr		<= r_i_wr_addr +1'b1;
			else
				r_i_wr_addr		<= r_i_wr_addr;
		end
		
		r_i_wr_en			<= i_wvalid && o_wready;
		r_i_wr_data			<= w_i_wr_data;			
		r_i_wr_datamask		<= w_i_wr_datamask;		
		
		if(i_wvalid && o_wready)
		begin
			r_wr_cnt	<= r_wr_cnt +1'b1;			
		end
		
		if(w_empty_rise || r_awaddr_fifo_rd_en)
		begin
			r_i_wr_addr		<= w_wr_addr_fifo;
			r_wr_i_aburst   <= w_i_awburst_fifo;
			r_wr_cnt		<= 16'b0;			
		end
	
		if(o_rvalid && i_rready) r_rlast_cnt	<= r_rlast_cnt + 1'b1;
		
		if(o_rlast  && i_rready) r_rlast_cnt	<= 16'b0;
		
		if(w_wr_b_done)
		begin
			r_wr_b_count 	<= 9'd0;			
		end
		
		if (w_o_wr_ack)
		begin
			if(w_wr_b_done)
			begin
				r_wr_b_count 	<= 1'b1;
			end
			else
			begin
				r_wr_b_count 	<= r_wr_b_count + 1'b1;
			end
		end
	end	
end


wire w_arburst_full;
wire w_araddr_full;
wire w_arid_full;
wire w_arlen_full;

assign w_ar_full = w_arburst_full || w_araddr_full || w_arid_full || w_arlen_full;


Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(8),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
inst_arburst_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_arvalid  && w_arready)     , //(I) FIFO Write Enable
  .I_Wr_Data({6'b0,w_i_arburst})   , //(I) FIFO Write Data
  .I_Rd_En(r_ar_sample_rd_en)     , //(I) FIFO Read Enable
  .O_Rd_Data(w_i_arburst_fifo)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full(w_arburst_full)   , //(O) FIFO Write Full
  .O_Rd_Empty()  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);


Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(32),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
u_rd_addr_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_arvalid  && w_arready)     , //(I) FIFO Write Enable
  .I_Wr_Data(w_i_rd_addr)   , //(I) FIFO Write Data
  .I_Rd_En(r_ar_sample_rd_en)     , //(I) FIFO Read Enable
  .O_Rd_Data(w_rd_addr_fifo)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full(w_araddr_full)   , //(O) FIFO Write Full
  .O_Rd_Empty(w_rd_addr_empty)  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);

wire w_awburst_full;
wire w_awaddr_full;
wire w_awid_full;
wire w_awlen_full;

assign w_aw_full = w_awaddr_full || w_awid_full;

Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(48),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
u_wr_addr_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_awvalid  && w_awready)     , //(I) FIFO Write Enable
  .I_Wr_Data({6'b0,w_i_awburst,w_i_awlen,w_i_wr_addr})   , //(I) FIFO Write Data
  .I_Rd_En(w_awaddr_fifo_rd_en)     , //(I) FIFO Read Enable
  .O_Rd_Data(w_fifo_aw)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full(w_awaddr_full)   , //(O) FIFO Write Full
  .O_Rd_Empty(w_wr_addr_empty)  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);

Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(8),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
inst_awid_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_awvalid  && w_awready)     , //(I) FIFO Write Enable
  .I_Wr_Data(w_i_awid)   , //(I) FIFO Write Data
  .I_Rd_En(o_bvalid && i_bready)     , //(I) FIFO Read Enable
  .O_Rd_Data(o_bid)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full(w_awid_full)   , //(O) FIFO Write Full
  .O_Rd_Empty()  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);

Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(8),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
inst_arid_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_arvalid && w_arready)     , //(I) FIFO Write Enable
  .I_Wr_Data(w_i_arid)   , //(I) FIFO Write Data
  .I_Rd_En(o_rlast && i_rready)     , //(I) FIFO Read Enable
  .O_Rd_Data(o_rid)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full(w_arid_full)   , //(O) FIFO Write Full
  .O_Rd_Empty()  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);

Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(8),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
inst_respon_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_wr_b_done)     , //(I) FIFO Write Enable
  .I_Wr_Data(8'b1)   , //(I) FIFO Write Data
  .I_Rd_En(i_bready)     , //(I) FIFO Read Enable
  .O_Rd_Data()  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full()   , //(O) FIFO Write Full
  .O_Rd_Empty(w_fifo_bvalid)  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);

Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(8),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
inst_rd_brust_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_arvalid && w_arready)     , //(I) FIFO Write Enable
  .I_Wr_Data(w_i_arlen)   , //(I) FIFO Write Data
  .I_Rd_En(r_ar_sample_rd_en)     , //(I) FIFO Read Enable
  .O_Rd_Data(w_arlen_fifo)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full(w_arlen_full)   , //(O) FIFO Write Full
  .O_Rd_Empty()  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);

Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(8),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
inst_rd_last_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_arvalid && w_arready)     , //(I) FIFO Write Enable
  .I_Wr_Data(w_i_arlen)   , //(I) FIFO Write Data
  .I_Rd_En(o_rlast && o_rvalid && i_rready)     , //(I) FIFO Read Enable
  .O_Rd_Data(w_arlen_rlast_fifo)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full()   , //(O) FIFO Write Full
  .O_Rd_Empty()  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);

Ddr_Ctrl_Sc_Fifo#
(
.DATA_WIDTH(8),
.DATA_DEPTH(32),
.INITIAL_VALUE(8'b0)
)
inst_respon_len_fifo(
  .Sys_Clk(axi_clk)     , //System Clock
  .Sync_Clr(~nrst)    , //Sync Reset
  .I_Wr_En(w_i_awvalid  && w_awready)     , //(I) FIFO Write Enable
  .I_Wr_Data(w_i_awlen)   , //(I) FIFO Write Data
  .I_Rd_En(w_wr_b_done)     , //(I) FIFO Read Enable
  .O_Rd_Data(w_blen_fifo)  , //(O) FIFO Read Data
  .O_Data_Num()  , //(O) FIFO Data Number
  .O_Wr_Full(w_awlen_full)   , //(O) FIFO Write Full
  .O_Rd_Empty()  , //(O) FIFO Write Empty
  .O_Fifo_Err()    //Fifo Error

);


assign debug_wr_busy	 =	w_o_wr_busy;
assign debug_wr_data     =	r_i_wr_data;
assign debug_wr_datamask =	r_i_wr_datamask;
assign debug_wr_addr     =	r_i_wr_addr;
assign debug_wr_en       =	r_i_wr_en;
assign debug_wr_addr_en  =	r_i_wr_addr_en;
assign debug_wr_ack      =	w_o_wr_ack;

assign debug_rd_busy	 = 	w_o_rd_busy;
assign debug_rd_addr     = 	r_i_rd_addr_p;
assign debug_rd_addr_en  = 	r_i_rd_addr_en;
assign debug_rd_en       = 	w_i_rd_en;
assign debug_rd_data	 = 	w_o_rd_data;
assign debug_rd_valid    = 	w_o_rd_valid;
assign debug_rd_ack      =  w_o_rd_ack;


//efx_ddr3_soft_controller inst_efx_ddr3
efx_ddr3_soft_controller inst_efx_ddr3
(	
	.clk(axi_clk),
	.core_clk(core_clk),
	.tac_clk(tac_clk),
	.twd_clk(twd_clk),	
	.tdqss_clk(tdqss_clk),
	
	.reset_n(nrst),
	//.nrst(nrst),
	
	.wr_busy(w_o_wr_busy),
    .wr_data(r_i_wr_data),
    .wr_datamask(r_i_wr_datamask),
    .wr_addr(r_i_wr_addr),
    .wr_en(r_i_wr_en),
	.wr_addr_en(r_i_wr_en),
    .wr_ack(w_o_wr_ack),

    .rd_busy(w_o_rd_busy),
    .rd_addr(r_i_rd_addr_p),
	.rd_addr_en(r_i_rd_addr_en),
    .rd_en(w_i_rd_en),
    .rd_data(w_o_rd_data),
    .rd_valid(w_o_rd_valid),
    .rd_ack(w_o_rd_ack),

	.reset(reset),
	.cs(cs),
	.ras(ras),
	.cas(cas),
	.we(we),
	.cke(cke),    
	.addr(addr),
	.ba(ba),
	.odt(odt),
	.o_dm_hi(o_dm_hi),
	.o_dm_lo(o_dm_lo),

	.i_dq_hi(i_dq_hi),
	.i_dq_lo(i_dq_lo),

	.o_dq_hi(o_dq_hi),
	.o_dq_lo(o_dq_lo),

	.o_dq_oe(o_dq_oe),

	.i_dqs_hi(i_dqs_hi),
	.i_dqs_lo(i_dqs_lo),
	.i_dqs_n_hi(i_dqs_n_hi),
	.i_dqs_n_lo(i_dqs_n_lo),


	.o_dqs_hi(o_dqs_hi),
	.o_dqs_lo(o_dqs_lo),
	.o_dqs_n_hi(o_dqs_n_hi),
	.o_dqs_n_lo(o_dqs_n_lo),

	.o_dqs_oe(o_dqs_oe),
	.o_dqs_n_oe(o_dqs_n_oe),

	.shift(shift),
	.shift_sel(shift_sel),
	.shift_ena(shift_ena),
	.cal_ena(cal_ena),
	.cal_done(cal_done),
	.cal_pass(cal_pass)
);


endmodule
