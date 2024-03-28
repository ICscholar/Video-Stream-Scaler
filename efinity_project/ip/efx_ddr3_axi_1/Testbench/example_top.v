`include "ddr3_controller.vh"

module example_top
(
input clk,
input ddr_core_clk,
input ddr_twd_clk,
input ddr_tdqss_clk,
input ddr_tac_clk,
input reset_n, //active_low
input pll_lock, //pll_lock
input pll1_lock, //pll1_lock

output ddr_pll_rstn,
output sys_pll_rstn, 

output ddr_reset,
output ddr_cs,
output ddr_ras,
output ddr_cas,
output ddr_we,
output ddr_cke,
output [15:0]ddr_addr,
output [2:0]ddr_ba,
output ddr_odt,
output [`DRAM_GROUP-1'b1:0] o_ddr_dm_hi,
output [`DRAM_GROUP-1'b1:0] o_ddr_dm_lo,

input [`DRAM_GROUP-1'b1:0]i_ddr_dqs_hi,
input [`DRAM_GROUP-1'b1:0]i_ddr_dqs_lo,
output [`DRAM_GROUP-1'b1:0]o_ddr_dqs_hi,
output [`DRAM_GROUP-1'b1:0]o_ddr_dqs_lo,
output [`DRAM_GROUP-1'b1:0]o_ddr_dqs_oe,

input [`DRAM_GROUP-1'b1:0] i_ddr_dqs_n_hi,
input [`DRAM_GROUP-1'b1:0] i_ddr_dqs_n_lo, 
output [`DRAM_GROUP-1'b1:0] o_ddr_dqs_n_hi,
output [`DRAM_GROUP-1'b1:0] o_ddr_dqs_n_lo,
output [`DRAM_GROUP-1'b1:0] o_ddr_dqs_n_oe,

input [`DRAM_WIDTH-1'b1:0] i_ddr_dq_hi,
input [`DRAM_WIDTH-1'b1:0] i_ddr_dq_lo,

output [`DRAM_WIDTH-1'b1:0] o_ddr_dq_hi,
output [`DRAM_WIDTH-1'b1:0] o_ddr_dq_lo,

output [`DRAM_WIDTH-1'b1:0] o_ddr_dq_oe,

output [2:0]			ddr_shift,
output [4:0]			ddr_shift_sel,
output 					ddr_shift_ena,

output 	wire			ddr_cal_done,
output 	wire			ddr_cal_pass,
output  wire            pass,
output  wire            done
);

//parameter DDR3_MODE = `DDR3_MODE; //1-Native, 2-AXI4 

assign ddr_pll_rstn = 1'b1;
assign sys_pll_rstn = 1'b1;

wire w_nrst;
assign w_nrst = (reset_n && pll_lock && pll1_lock);

wire [2:0] cal_shift_val;
wire [7:0] cal_fail_log;
wire w_wr_busy;
wire [`WFIFO_WIDTH-1'b1:0]w_wr_data;
wire [`DM_BIT_WIDTH-1'b1:0]w_wr_datamask;
wire [31:0]w_wr_addr;
wire w_wr_en;
wire w_wr_ack;

wire w_rd_busy;
wire [31:0] w_rd_addr;
wire w_rd_en;
wire [`WFIFO_WIDTH-1'b1:0]w_rd_data;
wire w_rd_valid;

wire w_cal_done;

assign ddr_cal_done = w_cal_done;

parameter START_ADDR = 32'h000000;
`ifdef RTL_SIM
	parameter END_ADDR = 32'h0000100;
`else
	parameter END_ADDR = 32'h1ffffff;
`endif

generate
   if (`DDR3_MODE == 1) //Native
   begin
   	  memory_checker_native #(
	  .START_ADDR(START_ADDR),
          .END_ADDR(32'h0008000)
	  ) u0(
   	  	.clk		(clk),
   	  	.reset_n	(w_nrst),
   	  	.test_start	(w_cal_done),
   	  	.wr_busy	(w_wr_busy),
   	  	.wr_data	(w_wr_data),
   	  	.wr_datamask(w_wr_datamask),
   	  	.wr_addr	(w_wr_addr),
   	  	.wr_en		(w_wr_en),
   	  	.wr_ack		(w_wr_ack),

   	  	.rd_busy	(w_rd_busy),
   	  	.rd_addr	(w_rd_addr),
   	  	.rd_en		(w_rd_en),
   	  	.rd_data	(w_rd_data),
   	  	.rd_valid	(w_rd_valid),

   	  	.test_pass	(pass),
   	  	.test_done	(done)
   	  );

   	  efx_ddr3_axi_1 u1
   	  (	
   	  	.clk		    (clk),
   	  	.core_clk	(ddr_core_clk),
   	  	.tac_clk	(ddr_tac_clk),
   	  	.twd_clk	(ddr_twd_clk),	
   	  	.tdqss_clk	(ddr_tdqss_clk),
   	  	.reset_n	    (w_nrst),

   	  	.reset		(ddr_reset),
   	  	.cs			(ddr_cs),
   	  	.ras		(ddr_ras),
   	  	.cas		(ddr_cas),
   	  	.we			(ddr_we),
   	  	.cke		(ddr_cke),    
   	  	.addr		(ddr_addr),
   	  	.ba			(ddr_ba),
   	  	.odt		(ddr_odt),
   	  	.o_dm_hi	(o_ddr_dm_hi),
   	  	.o_dm_lo	(o_ddr_dm_lo),

   	  	.i_dq_hi	(i_ddr_dq_hi),
   	  	.i_dq_lo	(i_ddr_dq_lo),

   	  	.o_dq_hi	(o_ddr_dq_hi),
   	  	.o_dq_lo	(o_ddr_dq_lo),
   	  	.o_dq_oe	(o_ddr_dq_oe),
   	  	.i_dqs_hi	(i_ddr_dqs_hi),
   	  	.i_dqs_lo	(i_ddr_dqs_lo),
   	  	.i_dqs_n_hi	(i_ddr_dqs_n_hi),
   	  	.i_dqs_n_lo	(i_ddr_dqs_n_lo),

   	  	.o_dqs_hi	(o_ddr_dqs_hi),
   	  	.o_dqs_lo	(o_ddr_dqs_lo),
   	  	.o_dqs_n_hi	(o_ddr_dqs_n_hi),
   	  	.o_dqs_n_lo	(o_ddr_dqs_n_lo),

   	  	.o_dqs_oe	(o_ddr_dqs_oe),
   	  	.o_dqs_n_oe	(o_ddr_dqs_n_oe),

   	  	.wr_busy	(w_wr_busy),
   	  	.wr_data	(w_wr_data),
   	  	.wr_datamask(w_wr_datamask),
   	  	.wr_addr	(w_wr_addr),
   	  	.wr_en		(w_wr_en),
		.wr_addr_en	(w_wr_en),
		.wr_ack		(w_wr_ack),

		.rd_busy	(w_rd_busy),
		.rd_addr	(w_rd_addr),
		.rd_addr_en	(w_rd_en),
		.rd_en		(1'b1),
		.rd_data	(w_rd_data),
		.rd_valid	(w_rd_valid),
		.rd_ack		(),

		.shift(ddr_shift),
		.shift_sel(ddr_shift_sel),
		.shift_ena(ddr_shift_ena),
		.cal_ena(1'b1),
		.cal_done(w_cal_done),
		.cal_pass(ddr_cal_pass)
	);
   end
   else //AXI4
   begin
		wire 		reset;
		wire		io_systemReset;
		wire 	    io_memoryReset;		
				
		wire 	    io_memoryResetn;		
		wire [1:0]  io_ddrA_b_payload_resp=2'b00;
		wire axi4Interrupt;
		wire [7:0] axi_awid;
		wire [31:0]	axi_awaddr;
		wire [7:0]	axi_awlen;
		wire [2:0]	axi_awsize;
		wire [1:0]	axi_awburst;
		wire		axi_awlock;
		wire [3:0]	axi_awcache;
		wire [2:0]	axi_awprot;
		wire [3:0]	axi_awqos;
		wire [3:0]	axi_awregion;
		wire		axi_awvalid;
		wire		axi_awready;
		wire [31:0]	axi_wdata;
		wire [3:0] axi_wstrb;
		wire		axi_wvalid;
		wire		axi_wlast;
		wire		axi_wready;
		wire [7:0] axi_bid;
		wire [1:0] axi_bresp;
		wire		axi_bvalid;
		wire		axi_bready;
		wire [7:0]	axi_arid;
		wire [31:0]	axi_araddr;
		wire [7:0]	axi_arlen;
		wire [2:0]	axi_arsize;
		wire [1:0]	axi_arburst;
		wire		axi_arlock;
		wire [3:0]	axi_arcache;
		wire [2:0]	axi_arprot;
		wire [3:0]	axi_arqos;
		wire [3:0]	axi_arregion;
		wire		axi_arvalid;
		wire		axi_arready;
		wire [7:0]	axi_rid;
		wire [31:0]	axi_rdata;
		wire [1:0]	axi_rresp;
		wire		axi_rlast;
		wire		axi_rvalid;
		wire		axi_rready;
		wire userInterrupt_0;
		wire [15:0] io_apbSlave_0_PADDR;
		wire		io_apbSlave_0_PSEL;
		wire		io_apbSlave_0_PENABLE;
		wire		io_apbSlave_0_PREADY;
		wire		io_apbSlave_0_PWRITE;
		wire [31:0] io_apbSlave_0_PWDATA;
		wire [31:0] io_apbSlave_0_PRDATA;
		wire		io_apbSlave_0_PSLVERROR;
		wire [7:0] m_aid_0;
		wire [31:0] m_aaddr_0;
		wire [7:0]  m_alen_0;
		wire [2:0]  m_asize_0;
		wire [1:0]  m_aburst_0;
		wire [1:0]  m_alock_0;
		wire		m_avalid_0;
		wire		m_aready_0;
		wire		m_awready_0;
		wire		m_arready_0;
		wire		m_atype_0;
		wire [7:0]  m_wid_0;
		wire [127:0] m_wdata_0;
		wire [15:0]	m_wstrb_0;
		wire		m_wlast_0;
		wire		m_wvalid_0;
		wire		m_wready_0;
		wire [7:0] m_rid_0;
		wire [127:0] m_rdata_0;
		wire		m_rlast_0;
		wire		m_rvalid_0;
		wire		m_rready_0;
		wire [1:0] m_rresp_0;
		wire [7:0] m_bid_0;
		wire [1:0] m_bresp_0;
		wire		m_bvalid_0;
		wire		m_bready_0;
		wire		m_awvalid_0;
		wire		m_arvalid_0;
		wire		m_pass_0;
		wire		m_start_0;
		wire		io_axiMasterReset_0;
		wire		io_ddrA_arw_valid;
		wire		io_ddrA_arw_ready;
		wire [31:0] io_ddrA_arw_payload_addr;
		wire [7:0] io_ddrA_arw_payload_id;
		wire [7:0] io_ddrA_arw_payload_len;
		wire [2:0] io_ddrA_arw_payload_size;
		wire [1:0] io_ddrA_arw_payload_burst;
		wire [1:0] io_ddrA_arw_payload_lock;
		wire		io_ddrA_arw_payload_write;
		wire [7:0] io_ddrA_w_payload_id;
		wire		io_ddrA_w_valid;
		wire		io_ddrA_w_ready;
		wire [127:0] io_ddrA_w_payload_data;
		wire [15:0] io_ddrA_w_payload_strb;
		wire		io_ddrA_w_payload_last;
		wire		io_ddrA_b_valid;
		wire		io_ddrA_b_ready;
		wire [7:0] io_ddrA_b_payload_id;
		wire		io_ddrA_r_valid;
		wire		io_ddrA_r_ready;
		wire [127:0] io_ddrA_r_payload_data;
		wire [7:0] io_ddrA_r_payload_id;
		wire [1:0] io_ddrA_r_payload_resp;
		wire		io_ddrA_r_payload_last;
		wire		dyn_pll_phase_en;
		wire [2:0] dyn_pll_phase_sel;


		assign io_memoryResetn = w_nrst;
	  
		memory_checker_axi #(
		.START_ADDR(START_ADDR),
		.STOP_ADDR(END_ADDR),
		.ALEN(63),
		.WIDTH(128)
		) memcheck_0 (
		.axi_clk(clk),
		.rstn(io_memoryResetn),
		.start(w_cal_done),
		.aid(m_aid_0),
		.aaddr(m_aaddr_0),
		.alen(m_alen_0),
		.asize(m_asize_0),
		.aburst(m_aburst_0),
		.alock(m_alock_0),
		.avalid(m_avalid_0),
		.aready(m_aready_0),
		.atype(m_atype_0),
		.wid(m_wid_0),
		.wdata(m_wdata_0),
		.wstrb(m_wstrb_0),
		.wlast(m_wlast_0),
		.wvalid(m_wvalid_0),
		.wready(m_wready_0),
		.rid(m_rid_0),
		.rdata(m_rdata_0),
		.rlast(m_rlast_0),
		.rvalid(m_rvalid_0),
		.rready(m_rready_0),
		.rresp(m_rresp_0),
		.bid(m_bid_0),
		.bvalid(m_bvalid_0),
		.bready(m_bready_0),
		.pass(pass),
		.done(done)
		);



		efx_ddr3_axi_1 inst_ddr3_axi
		(	
			.core_clk	(ddr_core_clk),
			.tac_clk	(ddr_tac_clk),
			.twd_clk	(ddr_twd_clk),	
			.tdqss_clk	(ddr_tdqss_clk),

			
			.reset		(ddr_reset),
			.cs			(ddr_cs),
			.ras		(ddr_ras),
			.cas		(ddr_cas),
			.we			(ddr_we),
			.cke		(ddr_cke),    
			.addr		(ddr_addr),
			.ba			(ddr_ba),
			.odt		(ddr_odt),
			.o_dm_hi	(o_ddr_dm_hi),
			.o_dm_lo	(o_ddr_dm_lo),

			.i_dq_hi	(i_ddr_dq_hi),
			.i_dq_lo	(i_ddr_dq_lo),

			.o_dq_hi	(o_ddr_dq_hi),
			.o_dq_lo	(o_ddr_dq_lo),

			.o_dq_oe	(o_ddr_dq_oe),

			.i_dqs_hi	(i_ddr_dqs_hi),
			.i_dqs_lo	(i_ddr_dqs_lo),
			.i_dqs_n_hi	(i_ddr_dqs_n_hi),
			.i_dqs_n_lo	(i_ddr_dqs_n_lo),


			.o_dqs_hi	(o_ddr_dqs_hi),
			.o_dqs_lo	(o_ddr_dqs_lo),
			.o_dqs_n_hi	(o_ddr_dqs_n_hi),
			.o_dqs_n_lo	(o_ddr_dqs_n_lo),

			.o_dqs_oe	(o_ddr_dqs_oe),
			.o_dqs_n_oe	(o_ddr_dqs_n_oe),

			.clk(clk),
			.reset_n(io_memoryResetn),
			.axi_avalid(m_avalid_0),
			.axi_aready(m_aready_0),
			.axi_aaddr(m_aaddr_0),
			.axi_aid(m_aid_0),
			.axi_alen(m_alen_0),
			.axi_asize(m_asize_0),
			.axi_aburst(m_aburst_0),
			.axi_alock(m_alock_0),
			.axi_atype(m_atype_0),
			
			.axi_wid(m_wid_0),
			.axi_wvalid(m_wvalid_0),
			.axi_wready(m_wready_0),
			.axi_wdata(m_wdata_0),
			.axi_wstrb(m_wstrb_0),
			.axi_wlast(m_wlast_0),
			
			.axi_bvalid(m_bvalid_0),
			.axi_bready(m_bready_0),
			.axi_bid(m_bid_0),
			.axi_bresp(),
			
			.axi_rvalid(m_rvalid_0),
			.axi_rready(m_rready_0),
			.axi_rdata(m_rdata_0),
			.axi_rid(m_rid_0),
			.axi_rresp(m_rresp_0),
			.axi_rlast(m_rlast_0),

			.shift(ddr_shift),
			.shift_sel(ddr_shift_sel),
			.shift_ena(ddr_shift_ena),
			.cal_ena(1'b1),
			.cal_done(w_cal_done),
			.cal_pass(ddr_cal_pass)
		);
   end
endgenerate

endmodule
