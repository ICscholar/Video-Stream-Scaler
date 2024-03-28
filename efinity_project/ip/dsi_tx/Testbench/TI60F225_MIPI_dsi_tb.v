`timescale 1 ns / 1 ps

module TI60F225_MIPI_dsi_tb();

//-----------------------
parameter   MAX_HRES        = 16'd1080;
parameter   MAX_VRES        = 12'd4;
parameter    HSP                = 10'd2;
parameter    HBP                = 10'd2;
parameter    HFP                = 10'd246;
parameter    VSP                = 6'd5;
parameter    VBP                = 6'd8;
parameter    VFP                = 6'd32;
//------------------------//
parameter	FIFO_WIDTH	= 4'd12;
parameter	PIXEL		= 5'd8;

reg		i_pclk;
reg		o_pclk;
reg		i_sys_clk;
reg		mipi_clk;
reg		i_mipi_tx_pclk;
reg		i_arstn;
reg		i_arstn_dsi_ctrl;
reg     i_tx_arstn;
reg		r_rstn_cmd;

wire[FIFO_WIDTH-1:0]	video_x;
wire[FIFO_WIDTH-1:0]	video_y;
wire					video_valid;
wire					video_de;
wire					video_hs;
wire					video_vs;

wire[FIFO_WIDTH-1:0]	out_x;
wire[FIFO_WIDTH-1:0]	out_y;
wire					out_valid;
wire					out_de;
wire					out_hs;
wire					out_vs;
wire[47:0]				out_data;
wire[FIFO_WIDTH-1:0]	w_unpack_x;
wire[FIFO_WIDTH-1:0]	w_unpack_y;
wire					w_unpack_valid;
wire					w_unpack_de;
wire					w_unpack_hs;
wire					w_unpack_vs;
wire[23:0]				w_unpack_data;
wire[FIFO_WIDTH-1:0]	pg_x;
wire[FIFO_WIDTH-1:0]	pg_y;
wire					pg_valid;
wire					pg_de;
wire					pg_hs;
wire					pg_vs;
wire[7:0]				pg_data;

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

wire	[31:0]w_axi_rdata;
wire	w_axi_awready;
wire	w_axi_wready;
wire	w_axi_arready;
wire	w_axi_rvalid;
wire	w_axi_bvalid;

wire	[6:0]w_axi_awaddr;
wire	w_axi_awvalid;
wire	[31:0]w_axi_wdata;
wire	w_axi_wvalid;
wire	w_axi_bready;
wire	[6:0]w_axi_araddr;
wire	w_axi_arvalid;
wire	w_axi_rready;

wire	[6:0]w_axi_awaddr_0;
wire	w_axi_awvalid_0;
wire	[31:0]w_axi_wdata_0;
wire	w_axi_wvalid_0;
wire	w_axi_bready_0;
wire	[6:0]w_axi_araddr_0;
wire	w_axi_arvalid_0;
wire	w_axi_rready_0;

wire	[6:0]w_axi_awaddr_1;
wire	w_axi_awvalid_1;
wire	[31:0]w_axi_wdata_1;
wire	w_axi_wvalid_1;
wire	w_axi_bready_1;
wire	[6:0]w_axi_araddr_1;
wire	w_axi_arvalid_1;
wire	w_axi_rready_1;

wire	[3:0]w_state;
wire	w_confdone;

wire	mipi_tx0_clk_LP_P_OUT;
wire	mipi_tx0_clk_LP_N_OUT;
wire	mipi_tx0_clk_HS_OE;
wire	mipi_tx0_data3_LP_P_OUT;
wire	mipi_tx0_data2_LP_P_OUT;
wire	mipi_tx0_data1_LP_P_OUT;
wire	mipi_tx0_data0_LP_P_OUT;
wire	mipi_tx0_data3_LP_N_OUT;
wire	mipi_tx0_data2_LP_N_OUT;
wire	mipi_tx0_data1_LP_N_OUT;
wire	mipi_tx0_data0_LP_N_OUT;
wire	[7:0] mipi_tx0_data0_HS_OUT;
wire	[7:0] mipi_tx0_data1_HS_OUT;
wire	[7:0] mipi_tx0_data2_HS_OUT;
wire	[7:0] mipi_tx0_data3_HS_OUT;
wire	mipi_tx0_data3_HS_OE;
wire	mipi_tx0_data2_HS_OE;
wire	mipi_tx0_data1_HS_OE;
wire	mipi_tx0_data0_HS_OE;
wire	mipi_tx0_data0_LP_P_IN;
wire	mipi_tx0_data0_LP_N_IN;

reg	r_rstn_video;
reg	r_pack_hs_1P;
reg	[15:0]r_hs_cnt;
reg [5:0]r_frame_cnt;
reg [5:0] r_syncbyte_cnt;
reg mipi_tx0_data0_HS_OE_1P;

initial
begin
	i_pclk	<= 1'b1;
	forever
		#4.00	i_pclk	<= ~i_pclk;
end

initial
begin
	o_pclk	<= 1'b1;
	forever
		#8.00	o_pclk	<= ~o_pclk;
end

initial
begin
	i_sys_clk	<= 1'b1;
	forever
		#10	i_sys_clk	<= ~i_sys_clk;
end

initial
begin
	mipi_clk	<= 1'b1;
	forever
		#5	mipi_clk	<= ~mipi_clk;
end

initial
begin
	i_mipi_tx_pclk	<= 1'b1;
	forever
		#4	i_mipi_tx_pclk	<= ~i_mipi_tx_pclk;
end

initial

begin
		i_arstn_dsi_ctrl <= 1'b0;	
	#20	i_arstn_dsi_ctrl <= 1'b1;
end

initial
begin
            i_arstn	<= 1'b0;	
	#99000	i_arstn	<= 1'b1;

#8000000
if (r_syncbyte_cnt == r_frame_cnt) begin  //make sure the test is not idle
    $display("TEST PASSED");
end
else begin
    $display("TEST FAILED");
end

$finish(1);
end

initial
begin
		i_tx_arstn	<= 1'b0;	
	#500000	i_tx_arstn	<= 1'b1;
	
end

reg		[31:0]r_axi_rdata;
reg 	r_axi_awready;
reg 	r_axi_wready;
reg 	r_axi_arready;
reg 	r_axi_rvalid;
reg 	r_axi_bvalid;

always@(negedge i_arstn or posedge i_sys_clk)
begin
	if (~i_arstn)
	begin
		r_axi_rdata		<= {32{1'b0}};
		r_axi_awready	<= 1'b0;
		r_axi_wready	<= 1'b0;
		r_axi_arready	<= 1'b0;
		r_axi_rvalid	<= 1'b0;
		r_axi_bvalid	<= 1'b0;
	end
	else
	begin
		if (w_axi_wvalid)
			r_axi_bvalid	<= 1'b1;
		
		if (r_axi_bvalid)
			r_axi_bvalid	<= 1'b0;
		
		if (w_axi_rready)
			r_axi_rvalid	<= 1'b1;
		else
			r_axi_rvalid	<= 1'b0;
		
		r_axi_rdata		<= {32{1'b0}};
		r_axi_awready	<= 1'b1;
		r_axi_wready	<= 1'b1;
		r_axi_arready	<= 1'b1;
	end
end
	

/* Panel driver NT35596 initialization */
panel_config
#(
	.INITIAL_CODE	("dsi_tb.mem"),
	.REG_DEPTH		(9'd53)
)
inst_panel_config
(
	.i_axi_clk		(i_sys_clk),
	.i_restn		(i_arstn),
	
	.i_axi_awready	(w_axi_awready	),
	.i_axi_wready	(w_axi_wready	),
	.i_axi_bvalid	(w_axi_bvalid	),
	.o_axi_awaddr	(w_axi_awaddr_0	),
	.o_axi_awvalid	(w_axi_awvalid_0	),
	.o_axi_wdata	(w_axi_wdata_0	),
	.o_axi_wvalid	(w_axi_wvalid_0	),
	.o_axi_bready	(w_axi_bready_0	),
	
	.i_axi_arready	(w_axi_arready	),
	.i_axi_rdata	(w_axi_rdata	),
	.i_axi_rvalid	(w_axi_rvalid	),
	.o_axi_araddr	(w_axi_araddr_0	),
	.o_axi_arvalid	(w_axi_arvalid_0	),
	.o_axi_rready	(w_axi_rready_0	),
	
	.o_addr_cnt		(),
	.o_state		(w_state		),
	.o_confdone		(w_confdone		),
	
	.i_dbg_we		(0		),
	.i_dbg_din		(0		),
	.i_dbg_addr		(0		),
	.o_dbg_dout		(		),
	.i_dbg_reconfig	(0	)
);

panel_config
#(
	.INITIAL_CODE	("dsi_hs_cmd_tb.mem"),
	.REG_DEPTH		(9'd54)
)
inst_panel_config_hs_cmd
(
	.i_axi_clk		(i_sys_clk),
	.i_restn		(r_rstn_cmd),
	
	.i_axi_awready	(w_axi_awready	),
	.i_axi_wready	(w_axi_wready	),
	.i_axi_bvalid	(w_axi_bvalid	),
	.o_axi_awaddr	(w_axi_awaddr_1	),
	.o_axi_awvalid	(w_axi_awvalid_1	),
	.o_axi_wdata	(w_axi_wdata_1	),
	.o_axi_wvalid	(w_axi_wvalid_1	),
	.o_axi_bready	(w_axi_bready_1	),
	
	.i_axi_arready	(w_axi_arready	),
	.i_axi_rdata	(w_axi_rdata	),
	.i_axi_rvalid	(w_axi_rvalid	),
	.o_axi_araddr	(w_axi_araddr_1	),
	.o_axi_arvalid	(w_axi_arvalid_1	),
	.o_axi_rready	(w_axi_rready_1	),
	
	.o_addr_cnt		(),
	.o_state		(),
	.o_confdone		(),
	
	.i_dbg_we		(0		),
	.i_dbg_din		(0		),
	.i_dbg_addr		(0		),
	.o_dbg_dout		(		),
	.i_dbg_reconfig	(0	)
);

assign	w_axi_awaddr	= w_confdone ? w_axi_awaddr_1 	: w_axi_awaddr_0 ;
assign	w_axi_awvalid	= w_confdone ? w_axi_awvalid_1 	: w_axi_awvalid_0;
assign	w_axi_wdata		= w_confdone ? w_axi_wdata_1 	: w_axi_wdata_0  ;
assign	w_axi_wvalid	= w_confdone ? w_axi_wvalid_1 	: w_axi_wvalid_0 ;
assign	w_axi_bready	= w_confdone ? w_axi_bready_1 	: w_axi_bready_0 ;
assign	w_axi_araddr	= w_confdone ? w_axi_araddr_1 	: w_axi_araddr_0 ;
assign	w_axi_arvalid	= w_confdone ? w_axi_arvalid_1 	: w_axi_arvalid_0;
assign	w_axi_rready	= w_confdone ? w_axi_rready_1 	: w_axi_rready_0 ;

vga_gen
#(
	.H_SyncPulse	(HSP		),           
	.H_BackPorch	(HBP		),  	          
	.H_ActivePix	(MAX_HRES	),	           
	.H_FrontPorch	(HFP		),
	.V_SyncPulse	(VSP		),
	.V_BackPorch	(VBP		),
	.V_ActivePix	(MAX_VRES	),
	.V_FrontPorch	(VFP		),
	.P_Cnt			(3'd1		)
)
inst_vga_gen
(
	.in_pclk	(i_pclk),
	.in_rstn	(w_confdone),//(i_arstn),
	
	.out_x		(video_x),
	.out_y		(video_y),
	.out_valid	(video_valid),
	.out_de		(video_de),
	.out_hs		(video_hs),
	.out_vs		(video_vs)
);

// Horizontal porch value must be multipled by PACK_BIT/PIXEL_BIT
data_pack
#(
	.PIXEL_BIT	(5'd24),           
	.PACK_BIT	(8'd48),  	          
	.FIFO_WIDTH	(FIFO_WIDTH),
	.HSP		(HSP/2),           
	.HBP		(HBP/2),  	          
	.MAX_HRES	(MAX_HRES/2),	           
	.HFP		(HFP/2),
	.VSP		(VSP		),
	.VBP		(VBP		),
	.MAX_VRES	(MAX_VRES	),
	.VFP		(VFP		),
	.P_Cnt		(3'd1)
)
inst_data_pack
(
	.in_pclk	(i_pclk),
	.out_pclk	(o_pclk),
	.in_rstn	(i_arstn),
	
	.in_x		(video_x),
	.in_y		(video_y),
	.in_valid	(video_valid),
	.in_de		(video_de),
	.in_hs		(video_hs),
	.in_vs		(video_vs),
	.in_data	({video_x[7:0], 4'b0, video_x[11:8], video_y[7:0]}),
	
	.out_x		(out_x),
	.out_y		(out_y),
	.out_valid	(out_valid),
	.out_de		(out_de),
	.out_hs		(out_hs),
	.out_vs		(out_vs),
	.out_data	(out_data)
);

always @ (posedge o_pclk)
begin
	if(~i_arstn)
	begin				
		r_rstn_video	<= 1'b0;
		r_rstn_cmd		<= 1'b0;
		r_pack_hs_1P	<= 1'b0;
		r_hs_cnt		<= 16'b0;
		r_frame_cnt		<= 6'b0;
	end
	else
	begin
		r_pack_hs_1P	<= out_hs;
		
		if ((out_y == MAX_VRES - 1) && (out_x == MAX_HRES/2 - 1))
			r_frame_cnt	<= r_frame_cnt + 1'b1;
					
		if 	(r_frame_cnt[0] && out_hs && ~r_pack_hs_1P)
			r_hs_cnt	<= r_hs_cnt + 1'b1;
		
		if (r_hs_cnt == VFP)
			r_rstn_video	<= 1'b1;
		
		if 	(r_frame_cnt[1])
			r_rstn_cmd	<= 1'b1;
	end
end

always @ (posedge i_mipi_tx_pclk) begin
	if(~r_rstn_video) begin				
		mipi_tx0_data0_HS_OE_1P <= 1'b0;
	end
	else begin
		mipi_tx0_data0_HS_OE_1P <= mipi_tx0_data0_HS_OE;
	end
end

always @ (posedge i_mipi_tx_pclk) begin
	if(~r_rstn_video) begin				
		r_syncbyte_cnt <= 6'd0;
	end
	else if (mipi_tx0_data0_HS_OE && ~mipi_tx0_data0_HS_OE_1P) begin
		r_syncbyte_cnt <= r_syncbyte_cnt + 6'd1;
		$display("Received frame no. %d", r_syncbyte_cnt);
	end
end

/* MIPI RX Channel 0 */
dsi_tx inst_efx_dsi_tx
(
    .reset_n			(i_arstn_dsi_ctrl),
    .clk				(mipi_clk),
    .reset_byte_HS_n	(i_arstn_dsi_ctrl),
    .clk_byte_HS		(i_mipi_tx_pclk),
    .reset_pixel_n		(r_rstn_video),
    .clk_pixel			(o_pclk),  // 1000*4/48=83
    // LVDS clock lane   
	.Tx_LP_CLK_P		(mipi_tx0_clk_LP_P_OUT),
    .Tx_LP_CLK_P_OE     (),
	.Tx_LP_CLK_N		(mipi_tx0_clk_LP_N_OUT),
    .Tx_LP_CLK_N_OE     (),
    .Tx_HS_C            (),
	.Tx_HS_enable_C		(mipi_tx0_clk_HS_OE),
	
	// ----- DLane -----------
    // LVDS data lane
    .Tx_LP_D_P			({mipi_tx0_data3_LP_P_OUT, mipi_tx0_data2_LP_P_OUT, mipi_tx0_data1_LP_P_OUT, mipi_tx0_data0_LP_P_OUT}),
    .Tx_LP_D_P_OE       ({mipi_tx0_data3_LP_P_OE, mipi_tx0_data2_LP_P_OE, mipi_tx0_data1_LP_P_OE, mipi_tx0_data0_LP_P_OE}),
	.Tx_LP_D_N			({mipi_tx0_data3_LP_N_OUT, mipi_tx0_data2_LP_N_OUT, mipi_tx0_data1_LP_N_OUT, mipi_tx0_data0_LP_N_OUT}),
    .Tx_LP_D_N_OE       ({mipi_tx0_data3_LP_N_OE, mipi_tx0_data2_LP_N_OE, mipi_tx0_data1_LP_N_OE, mipi_tx0_data0_LP_N_OE}),
	.Tx_HS_D_0			(mipi_tx0_data0_HS_OUT),
	.Tx_HS_D_1			(mipi_tx0_data1_HS_OUT),
	.Tx_HS_D_2			(mipi_tx0_data2_HS_OUT),
	.Tx_HS_D_3			(mipi_tx0_data3_HS_OUT),
	// control signal to LVDS IO
	.Tx_HS_enable_D		({mipi_tx0_data3_HS_OE, mipi_tx0_data2_HS_OE, mipi_tx0_data1_HS_OE, mipi_tx0_data0_HS_OE}),
	.Rx_LP_D_P			(mipi_tx0_data0_LP_P_IN),
	.Rx_LP_D_N			(mipi_tx0_data0_LP_N_IN),
	
    //AXI4-Lite Interface
    .axi_clk		(i_sys_clk		), 
    .axi_reset_n	(i_arstn			),
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
	
    .hsync				(~out_hs),
    .vsync				(~out_vs),
    .vc					(2'b0),
	.datatype			(6'h3E),   // data type of the Long Packet
    .pixel_data			({16'b0, out_data}),
    .pixel_data_valid	(out_valid),
	.haddr				(MAX_HRES),
    .TurnRequest_dbg    (0),
    .TurnRequest_done   (),
    .irq				()
);

endmodule
