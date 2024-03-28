
module TI60F225_MIPI_dsi
(
	i_arstn,
	i_fb_clk,
	i_sysclk,
	i_sysclk_div_2,
	i_mipi_rx_pclk,
	i_pll_locked,
	
	i_mipi_clk,
	i_mipi_txc_sclk,
	i_mipi_txd_sclk,
	i_mipi_tx_pclk,
	i_mipi_tx_pll_locked,

	o_lcd_rstn,
	o_pll_rstn,
	o_mipi_pll_rstn,

	mipi_dp_clk_LP_P_OUT,
	mipi_dp_clk_LP_N_OUT,
	mipi_dp_clk_HS_OUT,
	mipi_dp_clk_HS_OE,
	mipi_dp_data0_LP_P_OUT,
	mipi_dp_data1_LP_P_OUT,
	mipi_dp_data2_LP_P_OUT,	
	mipi_dp_data3_LP_P_OUT,
	
	mipi_dp_data0_LP_P_OE,
	mipi_dp_data1_LP_P_OE,
	mipi_dp_data2_LP_P_OE,
	mipi_dp_data3_LP_P_OE,
	
	mipi_dp_clk_RST,
	mipi_dp_data0_RST,
	mipi_dp_data1_RST,
	mipi_dp_data2_RST,
	mipi_dp_data3_RST,
	mipi_dp_clk_LP_P_OE,
	mipi_dp_clk_LP_N_OE,
	
	mipi_dp_data0_LP_N_OUT,
	mipi_dp_data1_LP_N_OUT,
	mipi_dp_data2_LP_N_OUT,
	mipi_dp_data3_LP_N_OUT,
	
	mipi_dp_data0_LP_N_OE,
	mipi_dp_data1_LP_N_OE,
	mipi_dp_data2_LP_N_OE,
	mipi_dp_data3_LP_N_OE,
	
	mipi_dp_data0_HS_OUT,
	mipi_dp_data1_HS_OUT,
	mipi_dp_data2_HS_OUT,
	mipi_dp_data3_HS_OUT,
	
	mipi_dp_data0_HS_OE,
	mipi_dp_data1_HS_OE,
	mipi_dp_data2_HS_OE,
	mipi_dp_data3_HS_OE,
	
	mipi_dp_data0_LP_P_IN,
	mipi_dp_data0_LP_N_IN
);

function integer log2;
	input	integer	val;
	integer	i;
	begin
		log2 = 0;
		for (i=0; 2**i<val; i=i+1)
			log2 = i+1;
	end
endfunction

parameter	MAX_HRES		= 12'd1080;
parameter	MAX_VRES		= 12'd1920;
parameter	HSP				= 8'd100;
parameter	HBP				= 8'd100;
parameter	HFP				= 8'd250;
parameter	VSP				= 6'd3;
parameter	VBP				= 6'd5;
parameter	VFP				= 6'd6;

input	wire	i_arstn;
input	wire	i_fb_clk;
input	wire	i_sysclk;
input	wire	i_sysclk_div_2;
input	wire	i_mipi_rx_pclk;
input	wire	i_pll_locked;

input	wire	i_mipi_clk;
input	wire	i_mipi_txc_sclk;
input	wire	i_mipi_txd_sclk;
input	wire	i_mipi_tx_pclk;
input	wire	i_mipi_tx_pll_locked;

output	wire	o_lcd_rstn;
output	wire	o_pll_rstn;
output	wire	o_mipi_pll_rstn;

output	wire	mipi_dp_clk_LP_P_OUT;
output	wire	mipi_dp_clk_LP_N_OUT;
output	wire	[7:0] 	mipi_dp_clk_HS_OUT;
output	wire	mipi_dp_clk_HS_OE;
output	wire	mipi_dp_data3_LP_P_OUT;
output	wire	mipi_dp_data2_LP_P_OUT;
output	wire	mipi_dp_data1_LP_P_OUT;
output	wire	mipi_dp_data0_LP_P_OUT;
output	wire	mipi_dp_data3_LP_N_OUT;
output	wire	mipi_dp_data2_LP_N_OUT;
output	wire	mipi_dp_data1_LP_N_OUT;
output	wire	mipi_dp_data0_LP_N_OUT;
output	wire	[7:0] 	mipi_dp_data0_HS_OUT;
output	wire	[7:0] 	mipi_dp_data1_HS_OUT;
output	wire	[7:0] 	mipi_dp_data2_HS_OUT;
output	wire	[7:0] 	mipi_dp_data3_HS_OUT;
output	wire	mipi_dp_data3_HS_OE;
output	wire	mipi_dp_data2_HS_OE;
output	wire	mipi_dp_data1_HS_OE;
output	wire	mipi_dp_data0_HS_OE;

output	wire	mipi_dp_clk_RST;
output	wire	mipi_dp_data0_RST;
output	wire	mipi_dp_data1_RST;
output	wire	mipi_dp_data2_RST;
output	wire	mipi_dp_data3_RST;
output	wire	mipi_dp_clk_LP_P_OE;
output	wire	mipi_dp_clk_LP_N_OE;
output	wire	mipi_dp_data3_LP_P_OE;
output	wire	mipi_dp_data3_LP_N_OE;
output	wire	mipi_dp_data2_LP_P_OE;
output	wire	mipi_dp_data2_LP_N_OE;
output	wire	mipi_dp_data1_LP_P_OE;
output	wire	mipi_dp_data1_LP_N_OE;
output	wire	mipi_dp_data0_LP_P_OE;
output	wire	mipi_dp_data0_LP_N_OE;

input  	wire	mipi_dp_data0_LP_P_IN;
input  	wire	mipi_dp_data0_LP_N_IN;

assign	mipi_dp_clk_RST		= ~i_arstn;
assign	mipi_dp_data0_RST	= ~i_arstn;
assign	mipi_dp_data1_RST	= ~i_arstn;
assign	mipi_dp_data2_RST	= ~i_arstn;
assign	mipi_dp_data3_RST	= ~i_arstn;

assign	o_lcd_rstn	= r_lcd_rstn;
assign	o_pll_rstn = i_arstn;
assign	o_mipi_pll_rstn = i_arstn;

////////////////////////////////////////////////////////////////
// System & Debugger
wire	w_sysclk_arstn;
wire	w_sysclk_arst;
wire	w_fb_clk_arstn;
wire	w_fb_clk_arst;
wire	w_fb_dp_arstn;
wire	w_fb_dp_arst;
wire	w_sys_dp_arstn;
wire	w_sys_dp_arst;

reg 	r_rstn_video;
reg 	[10:0]	r_hs_cnt;
reg 	[8:0]	r_frame_cnt;
reg		[19:0]	r_rst_cnt;
reg		r_lcd_rstn;

////////////////////////////////////////////////////////////////
// DSI Tx AXI
wire	[31:0]	w_axi_rdata;
wire	w_axi_awready;
wire	w_axi_wready;
wire	w_axi_arready;
wire	w_axi_rvalid;
wire	w_axi_bvalid;

wire	[6:0]	w_axi_awaddr;
wire	w_axi_awvalid;
wire	[31:0]	w_axi_wdata;
wire	w_axi_wvalid;
wire	w_axi_bready;
wire	[6:0]	w_axi_araddr;
wire	w_axi_arvalid;
wire	w_axi_rready;

wire	w_confdone;

////////////////////////////////////////////////////////////////

wire	i_rstn;
wire 	[11:0]w_vga_x;
wire 	[11:0]w_vga_y;
wire	w_vga_hs;
wire	w_vga_vs;
wire	w_vga_de;
wire	w_vga_valid;

wire 	[11:0]w_pg_x;
wire 	[11:0]w_pg_y;
wire	w_pg_valid;
wire	w_pg_de;
wire	w_pg_hs;
wire	w_pg_vs;
wire 	[7:0]w_pg_data_R;
wire 	[7:0]w_pg_data_G;
wire 	[7:0]w_pg_data_B;

wire 	[11:0]w_pack_x;
wire 	[11:0]w_pack_y;
wire	w_pack_valid;
wire	w_pack_de;
wire	w_pack_hs;
wire	w_pack_vs;
wire 	[47:0]w_pack_data;

reg 	[15:0]r_led_cnt;
reg		r_pack_vs_1P;
reg		r_pack_hs_1P;
reg		[15:0]r_hs_cnt;
reg 	[8:0]r_frame_cnt;
reg		r_clk_cnt;
reg 	[11:0]r_fast_x;
reg 	[11:0]r_fast_y;
reg		r_fast_valid;
reg		r_fast_de;
reg		r_fast_hs;
reg		r_fast_vs;
reg		[47:0]r_fast_data;
reg		r_pack_de_1P;
reg		r_sync;

reg 	[11:0]r_slow_x;
reg 	[11:0]r_slow_y;
reg		r_slow_valid;
reg		r_slow_de;
reg		r_slow_hs;
reg		r_slow_vs;
reg		[47:0]r_slow_data;

////////////////////////////////////////////////////////////////
reset_ctrl
#(
	.NUM_RST		(6),
	.CYCLE			(1),
	.IN_RST_ACTIVE	(6'b000000),
	.OUT_RST_ACTIVE	(6'b101010)
)
inst_reset_ctrl
(
	.i_arst				({{2{i_pll_locked}}, {4{r_rst_cnt[19]}}}),
	.i_clk				({{2{i_fb_clk}}, {2{i_fb_clk}}, {2{i_sysclk}}}),
	.o_srst				({	w_fb_clk_arst,       	w_fb_clk_arstn,
							w_fb_dp_arst,			w_fb_dp_arstn,
							w_sys_dp_arst,			w_sys_dp_arstn})
);

////////////////////////////////////////////////////////////////
always@(negedge i_arstn or posedge i_fb_clk)
begin
	if ( ~i_arstn)
	begin
		r_rst_cnt			<= {20{1'b0}};
		r_lcd_rstn			<= 1'b0;
	end
	else
	begin		
		if (~r_rst_cnt[19])
		begin
			r_rst_cnt	<= r_rst_cnt + 1'b1;
			
			if (r_rst_cnt[18] && r_rst_cnt[17])
				r_lcd_rstn	<= 1'b0;
			else
				r_lcd_rstn	<= 1'b1;
		end
		else
			r_lcd_rstn	<= 1'b1;
	end
end

// Panel driver initialization
panel_config
#(
	.INITIAL_CODE	("Panel_1080p_reg.mem"),
	.REG_DEPTH		(9'd15)
)
inst_panel_config
(
	.i_axi_clk		(i_fb_clk		),
	.i_restn		(w_fb_dp_arstn	),
	
	.i_axi_awready	(w_axi_awready	),
	.i_axi_wready	(w_axi_wready	),
	.i_axi_bvalid	(w_axi_bvalid	),
	.o_axi_awaddr	(w_axi_awaddr	),
	.o_axi_awvalid	(w_axi_awvalid	),
	.o_axi_wdata	(w_axi_wdata	),
	.o_axi_wvalid	(w_axi_wvalid	),
	.o_axi_bready	(w_axi_bready	),
	
	.i_axi_arready	(w_axi_arready	),
	.i_axi_rdata	(w_axi_rdata	),
	.i_axi_rvalid	(w_axi_rvalid	),
	.o_axi_araddr	(w_axi_araddr	),
	.o_axi_arvalid	(w_axi_arvalid	),
	.o_axi_rready	(w_axi_rready	),
	
	.o_addr_cnt		(			),
	.o_state		(			),
	.o_confdone		(w_confdone	),
	
	.i_dbg_we		(0	),
	.i_dbg_din		(0	),
	.i_dbg_addr		(0	),
	.o_dbg_dout		(	),
	.i_dbg_reconfig	(0	)
);

/* Video generation */
vga_gen
#(
	.H_SyncPulse	(HSP),
	.H_BackPorch	(HBP),
	.H_ActivePix	(MAX_HRES),
	.H_FrontPorch	(HFP),
	.V_SyncPulse	(VSP),
	.V_BackPorch	(VBP),
	.V_ActivePix	(MAX_VRES),
	.V_FrontPorch	(VFP),
	.P_Cnt			(3'd1)
)
inst_vga_gen
(
	.in_pclk	(i_mipi_clk	),
	.in_rstn	(w_confdone	),
	
	.out_hs		(w_vga_hs	),
	.out_vs		(w_vga_vs	),
	.out_de		(w_vga_de	),
	.out_valid	(w_vga_valid),
	.out_x		(w_vga_x	),
	.out_y		(w_vga_y	)
);



/* Pack data from 24bit to 48bit */
data_pack
#(
    .PIXEL_BIT    (5'd24),
    .PACK_BIT    (8'd48),
    .FIFO_WIDTH    (12),
    .HSP        (HSP/2), 
    .HBP        (HBP/2),    
    .MAX_HRES    (MAX_HRES/2),         
    .HFP        (HFP/2),
    .VSP        (VSP),
    .VBP        (VBP),
    .MAX_VRES    (MAX_VRES),
    .VFP        (VFP),
    .P_Cnt        (3'd1)
)
inst_data_pack
(
    .in_pclk    (i_mipi_clk    ),
    .out_pclk    (i_sysclk_div_2),    
    .in_rstn    (w_confdone    ),
    .in_x		(w_vga_x	),
    .in_y		(w_vga_y	),
    .in_valid	(w_vga_valid),
    .in_de		(w_vga_de	),
    .in_hs		(w_vga_hs	),
    .in_vs		(w_vga_vs	),
    .in_data	(24'b0		),
    	
    .out_x		(w_pack_x		),
    .out_y		(w_pack_y		),
    .out_valid	(w_pack_valid	),
    .out_de		(w_pack_de		),
    .out_hs		(w_pack_hs		),
    .out_vs		(w_pack_vs		),
    .out_data	()
);

assign    w_pack_data = r_frame_cnt[8:7] == 2'd0 ? {w_pack_x[7:0], 8'b0, 8'b0, w_pack_x[7:0], 8'b0, 8'b0} : 
                        r_frame_cnt[8:7] == 2'd1 ? {8'b0, w_pack_x[7:0], 8'b0, 8'b0, w_pack_x[7:0], 8'b0} :
                        r_frame_cnt[8:7] == 2'd2 ? {8'b0, 8'b0, w_pack_x[7:0], 8'b0, 8'b0, w_pack_x[7:0]} :
                        r_frame_cnt[8:7] == 2'd3 ? {w_pack_x[7:0]+w_pack_y[7:0], w_pack_x[7:0]+w_pack_y[7:0], w_pack_x[7:0]+w_pack_y[7:0], w_pack_x[7:0]+w_pack_y[7:0], w_pack_x[7:0]+w_pack_y[7:0], w_pack_x[7:0]+w_pack_y[7:0]} : 48'h0;

always@(negedge w_sys_dp_arstn or posedge i_sysclk_div_2)
begin
	if (~w_sys_dp_arstn)
	begin
		r_slow_x		<= 12'b0;
		r_slow_y		<= 12'b0;
		r_slow_valid	<= 1'b0;
		r_slow_de		<= 1'b0;
		r_slow_hs		<= 1'b0;
		r_slow_vs		<= 1'b0;
		r_slow_data		<= 48'b0;
		r_led_cnt		<= 16'b0;		
		r_rstn_video	<= 1'b0;
		r_pack_vs_1P	<= 1'b0;
		r_pack_hs_1P	<= 1'b0;
		r_hs_cnt		<= 16'b0;
		r_frame_cnt		<= 9'b0;
	end
	else
	begin		
		r_slow_x		<= r_fast_x;
		r_slow_y		<= r_fast_y;
		r_slow_valid	<= r_fast_valid;
		r_slow_de		<= r_fast_de;
		r_slow_hs		<= r_fast_hs;
		r_slow_vs		<= r_fast_vs;
		r_slow_data		<= r_fast_data;
		
		r_pack_vs_1P	<= w_pack_vs;
		r_pack_hs_1P	<= w_pack_hs;
		
		if (~w_pack_vs && r_pack_vs_1P)
			r_led_cnt		<= r_led_cnt + 1'b1;
						
		if ((w_pack_y == MAX_VRES - 1) && (w_pack_x == MAX_HRES/2 - 1))
			r_frame_cnt	<= r_frame_cnt + 1'b1;
					
		if 	(r_frame_cnt[0] && w_pack_hs && ~r_pack_hs_1P)
			r_hs_cnt	<= r_hs_cnt + 1'b1;
		
		if (r_hs_cnt == VFP)
			r_rstn_video	<= 1'b1;
	end
end

// MIPI DSI TX Channel
dsi_tx
#(
)
inst_efx_dsi_tx
(
	.reset_n			(w_sys_dp_arstn	),
	.clk				(i_mipi_clk		),	// 100
	.reset_byte_HS_n	(w_sys_dp_arstn	),
	.clk_byte_HS		(i_mipi_tx_pclk	),	// 1000/8=125
	.reset_pixel_n		(r_rstn_video	),
	.clk_pixel			(i_sysclk_div_2	),  // 1000/16=62.5
	// LVDS clock lane   
	.Tx_LP_CLK_P		(mipi_dp_clk_LP_P_OUT),
	.Tx_LP_CLK_P_OE     (mipi_dp_clk_LP_P_OE),
	.Tx_LP_CLK_N		(mipi_dp_clk_LP_N_OUT),
	.Tx_LP_CLK_N_OE     (mipi_dp_clk_LP_N_OE),
	.Tx_HS_C            (mipi_dp_clk_HS_OUT),
	.Tx_HS_enable_C		(mipi_dp_clk_HS_OE),
	
	// ----- DLane -----------
	// LVDS data lane
	.Tx_LP_D_P			({mipi_dp_data3_LP_P_OUT, mipi_dp_data2_LP_P_OUT, mipi_dp_data1_LP_P_OUT, mipi_dp_data0_LP_P_OUT}),
	.Tx_LP_D_P_OE       ({mipi_dp_data3_LP_P_OE, mipi_dp_data2_LP_P_OE, mipi_dp_data1_LP_P_OE, mipi_dp_data0_LP_P_OE}),
	.Tx_LP_D_N			({mipi_dp_data3_LP_N_OUT, mipi_dp_data2_LP_N_OUT, mipi_dp_data1_LP_N_OUT, mipi_dp_data0_LP_N_OUT}),
	.Tx_LP_D_N_OE       ({mipi_dp_data3_LP_N_OE, mipi_dp_data2_LP_N_OE, mipi_dp_data1_LP_N_OE, mipi_dp_data0_LP_N_OE}),
	.Tx_HS_D_0			(mipi_dp_data0_HS_OUT),
	.Tx_HS_D_1			(mipi_dp_data1_HS_OUT),
	.Tx_HS_D_2			(mipi_dp_data2_HS_OUT),
	.Tx_HS_D_3			(mipi_dp_data3_HS_OUT),
	// control signal to LVDS IO
	.Tx_HS_enable_D		({mipi_dp_data3_HS_OE, mipi_dp_data2_HS_OE, mipi_dp_data1_HS_OE, mipi_dp_data0_HS_OE}),
	.Rx_LP_D_P			(mipi_dp_data0_LP_P_IN),
	.Rx_LP_D_N			(mipi_dp_data0_LP_N_IN),
	
	//AXI4-Lite Interface
	.axi_clk		(i_fb_clk		), 
	.axi_reset_n	(w_fb_clk_arstn	),
	.axi_awaddr		(w_axi_awaddr	),//Write Address. byte address.
	.axi_awvalid	(w_axi_awvalid	),//Write address valid.
	.axi_awready	(w_axi_awready	),//Write address ready.
	.axi_wdata		(w_axi_wdata	),//Write data bus.
	.axi_wvalid		(w_axi_wvalid	),//Write valid.
	.axi_wready		(w_axi_wready	),//Write ready.
						  
	.axi_bvalid		(w_axi_bvalid	),//Write response valid.
	.axi_bready		(w_axi_bready	),//Response ready.      
	.axi_araddr		(w_axi_araddr	),//Read address. byte address.
	.axi_arvalid	(w_axi_arvalid	),//Read address valid.
	.axi_arready	(w_axi_arready	),//Read address ready.
	.axi_rdata		(w_axi_rdata	),//Read data.
	.axi_rvalid		(w_axi_rvalid	),//Read valid.
	.axi_rready		(w_axi_rready	),//Read ready.

    .hsync				(~w_pack_hs),
    .vsync				(~w_pack_vs),
	.vc					(2'b0					),
	.datatype			(6'h3E					),
    .pixel_data			({16'b0, w_pack_data}),
    .pixel_data_valid	(w_pack_valid),
	.haddr				(1080					),
	.TurnRequest_dbg    (1'b0					),
	.TurnRequest_done	(),
	.irq				()
);

endmodule
