`timescale 1 ns / 1 ns
module frame_buffer #(
	parameter I_VID_WIDTH 		= 	16,
	parameter O_VID_WIDTH 		= 	16,   
	parameter AXI_ID_WIDTH		=  	8, 
	parameter AXI_WR_ID			= 	8'ha0,
	parameter AXI_RD_ID			=	8'ha0,
	parameter AXI_ADDR_WIDTH	= 	32, 
	parameter AXI_DATA_WIDTH	= 	256,
	parameter MAX_VID_WIDTH		=	48 ,//video width 
	parameter MAX_VID_HIGHT		=	20 ,//wideo height
	parameter FB_NUM			= 	3,//2 buffer ,3 buffer      
	parameter START_ADDR		= 	0,
	parameter  BURST_LEN 		= 	8'd128,


  parameter AXI_BYTE_NUMBER = AXI_DATA_WIDTH/8 
	

)(
input	wire													i_clk	,
input	wire													i_vs, //active hgih
input	wire													i_de, //active high
input	wire	[I_VID_WIDTH-1:0] 			vin ,

input	wire													o_clk	,
output	wire													o_hs , //active high
output	wire													o_vs , //active hgih
output	wire													o_de , //active high
output	wire	[O_VID_WIDTH-1:0] 			vout ,

input	wire													axi_clk, 
input	wire													rst_n,

input	wire 	[12:0]									H_PRE_PORCH 	,
input	wire 	[12:0]									H_SYNC 				,
input	wire 	[12:0]									H_VALID 			,
input	wire 	[12:0]									H_BACK_PORCH 	,
input	wire 	[12:0]									V_PRE_PORCH 	,
input	wire 	[12:0]									V_SYNC 				,
input	wire 	[12:0]									V_VALID 			,
input	wire 	[12:0]									V_BACK_PORCH 	,

output 	wire 	[AXI_ID_WIDTH  -1:0]    axi_awid,      
output	wire 	[AXI_ADDR_WIDTH-1:0]   	axi_awaddr,    
output	wire 	[			  8-1:0]          axi_awlen,     
output	wire 				   [2:0]          axi_awsize,    
output	wire 				 [2-1:0]          axi_awburst,   
output	wire              						axi_awlock,    
output	wire 													axi_awvalid,   
input	wire 													axi_awready,  
 
output	wire	[AXI_ID_WIDTH-1:0]			axi_wid,
output	wire 	[AXI_DATA_WIDTH-1:0]   	axi_wdata,     
output	wire 	[AXI_BYTE_NUMBER-1:0]   axi_wstrb,     
output	wire 		              				axi_wlast,     
output	wire 		              				axi_wvalid,    
input	wire 		              				axi_wready,
                                                	
input	wire 	[AXI_ID_WIDTH-1:0]     	axi_bid,       
output	wire 	[2-1:0]            			axi_bresp,     
input	wire 	              					axi_bvalid,    
output	wire 	              					axi_bready,
                                              	
output	wire 	[AXI_ID_WIDTH-1:0]     	axi_arid,      
output	wire 	[AXI_ADDR_WIDTH-1:0]   	axi_araddr,    
output	wire 	[8-1:0]            			axi_arlen,     
output	wire 	[3-1:0]            			axi_arsize,    
output	wire 	[2-1:0]            			axi_arburst,   
output	wire 	                 				axi_arlock,    
output	wire 	                 				axi_arvalid,   
input	wire 	                 				axi_arready,
                                                	
input	wire 	[AXI_ID_WIDTH-1:0]     	axi_rid,       
input	wire 	[AXI_DATA_WIDTH-1:0]   	axi_rdata,     
input	wire 	[2-1:0]            			axi_rresp,     
input 	wire 	                				axi_rlast,     
input	wire 	                				axi_rvalid,    
output	wire 	                				axi_rready     ,

	input   wire [3:0] 	packet_type,
	input	wire [15:0] start_x,
	input	wire [15:0] start_y,
	input	wire [15:0] end_x,
	input	wire [15:0] end_y,
	input	wire [15:0] size_x,
	input	wire [15:0] size_y,
	input	wire [7:0]  Algorithm,
	input	wire 		param_valid

);

wire		wr_sw_ack ;
wire		wr_sw 		;
wire		rd_sw			;
wire		rd_sw_ack ;
wire	[1:0] wr_bank;
wire	[1:0] rd_bank;
wire	o_clk_rst_n;
wire	axi_clk_rst_n;
wire	i_clk_rst_n;  
wire		[31:0]		wr_start_addr;
wire		[31:0]    rd_start_addr; 

  rst_n_piple #(                       
	.DLY ( 3 )                        
)	u_i_clk_rst_pip(                                          
/*i*/.clk			(i_clk),                        
/*i*/.rst_n_i	(rst_n),                    
/*o*/.rst_n_o (i_clk_rst_n)            
);

  rst_n_piple #(                       
	.DLY ( 3 )                        
)	u_axi_rst_pip(                                          
/*i*/.clk			(axi_clk),                        
/*i*/.rst_n_i	(rst_n),                    
/*o*/.rst_n_o (axi_clk_rst_n)            
);

  rst_n_piple #(                       
	.DLY ( 3 )                        
)	u_o_clk_rst_pip(                                          
/*i*/.clk			(o_clk),                        
/*i*/.rst_n_i	(rst_n),                    
/*o*/.rst_n_o (o_clk_rst_n)            
);

	ddr_rx_buffer #(
	.I_VID_WIDTH (I_VID_WIDTH ),
	.AXI_DDR_WIDTH( AXI_DATA_WIDTH),
	.AXI_WR_ID(AXI_WR_ID),
	.AXI_ID_WIDTH(AXI_ID_WIDTH),
	.BURST_LEN(BURST_LEN)
)u_ddr_rx_buffer(
/*i*/.wrclk		  	(i_clk			 ),
/*i*/.rdclk		  	(axi_clk		 ),

/*i*/.wrclk_rst_n	(i_clk_rst_n	),
/*i*/.rdclk_rst_n	(axi_clk_rst_n	),

/*i*/.i_vs		  	(i_vs				 ),
/*i*/.i_de		  	(i_de				 ),
/*i*/.vin 		  	(vin 				 ), 
/*i*/.start_addr	(wr_start_addr),//({8'd0,wr_bank,22'd0}),
/*i*/.bank_sw_ack	(wr_sw_ack   ),
/*o*/.bank_sw 		(wr_sw  		 ),
/*o*/.AWID        (axi_awid		 ),
/*o*/.AWADDR	  (axi_awaddr  ),
/*o*/.AWLEN   	  (axi_awlen   ),
/*o*/.AWSIZE      (axi_awsize  ),
/*o*/.AWBURST     (axi_awburst ),
/*o*/.AWLOCK      (axi_awlock  ),
/*o*/.AWVALID     (axi_awvalid ),
/*i*/.AWREADY     (axi_awready ),
 
/*o*/.WID         (axi_wid     ),
/*o*/.WSTRB       (axi_wstrb   ),
/*o*/.WLAST       (axi_wlast   ),
/*o*/.WVALID      (axi_wvalid  ),
/*i*/.WREADY      (axi_wready  ),
/*o*/.WDATA       (axi_wdata   ),
                           
/*i*/.BID         (axi_bid     ),
/*i*/.BVALID      (axi_bvalid  ),
/*o*/.BREADY      (axi_bready  ) 
);
reg	tx_ena = 1'b0;
always @( posedge axi_clk or negedge axi_clk_rst_n )
begin
		if( !axi_clk_rst_n )
				tx_ena <= 1'b0;
		else if( axi_wlast )
				tx_ena <= 1'b1;
				
end




 ddr_tx_buffer #(
 .O_VID_WIDTH		( O_VID_WIDTH) ,
 .AXI_DDR_WIDTH (AXI_DATA_WIDTH),
 .AXI_RD_ID  		( AXI_RD_ID),
 .BURST_LEN(BURST_LEN),
 .AXI_ID_WIDTH(AXI_ID_WIDTH) 
 )u_ddr_tx_buffer(
/*i*/.wrclk				(axi_clk			),
/*i*/.wrclk_rst_n	(axi_clk_rst_n	),
/*i*/.rdclk				(o_clk				), 
/*i*/.rdclk_rst_n	(o_clk_rst_n	),
/*I*/.tx_ena			(tx_ena				), 
/*i*/.H_PRE_PORCH (H_PRE_PORCH  ),//( 50 			), 
/*i*/.H_SYNC 	 		(H_SYNC 	 		),//( 50 			), 
/*i*/.H_VALID 	 	(H_VALID 	 	  ),//( 48 			), 
/*i*/.H_BACK_PORCH(H_BACK_PORCH ),//( 50 			), 
/*i*/.V_PRE_PORCH (V_PRE_PORCH  ),//( 5 			), 
/*i*/.V_SYNC 	 		(V_SYNC 	 		),//( 5 			), 
/*i*/.V_VALID 	 	(V_VALID 	 	  ),//( 20 			), 
/*i*/.V_BACK_PORCH(V_BACK_PORCH ),//( 5 			), 

/*i*/.bank_sw_ack	(rd_sw_ack   	),
/*o*/.bank_sw 		(rd_sw  		 	),
/*i*/.start_addr	(rd_start_addr),//({8'd0,rd_bank,22'd0}),            
/*o*/.vout				(vout	 	 			),
/*o*/.hs_o				(o_hs    			),
/*o*/.vs_o				(o_vs    			),
/*o*/.de_o				(o_de    			), 
    
                     
/*o*/.ARID      	(axi_arid     ), 
/*o*/.ARADDR    	(axi_araddr   ), 
/*o*/.ARLEN     	(axi_arlen    ), 
/*o*/.ARSIZE    	(axi_arsize   ), 
/*o*/.ARBURST   	(axi_arburst  ), 
/*o*/.ARLOCK    	(axi_arlock   ), 
/*o*/.ARVALID   	(axi_arvalid  ), 
/*i*/.ARREADY   	(axi_arready  ), 
                	
/*I*/.RID       	(axi_rid      ), 
/*i*/.RRESP     	(axi_rresp    ), 
/*i*/.RLAST     	(axi_rlast    ), 
/*i*/.RVALID    	(axi_rvalid   ), 
/*o*/.RREADY    	(axi_rready   ), 
/*i*/.RDATA     	(axi_rdata    ) ,

/*i*/.packet_type   (packet_type),
/*i*/.start_x       (start_x    ),
/*i*/.start_y       (start_y    ),
/*i*/.end_x         (end_x      ),
/*i*/.end_y         (end_y      ),
/*i*/.size_x        (size_x     ),
/*i*/.size_y        (size_y     ),
/*i*/.Algorithm     ( Algorithm ),
/*i*/.param_valid   (param_valid)
);

bank_switch #(
		.FB_NUM					( FB_NUM),
		.MAX_VID_WIDTH 	( MAX_VID_WIDTH),
		.MAX_VID_HIGHT 	( MAX_VID_HIGHT),
		.START_ADDR			(	START_ADDR 	),
		.VID_DATA_WIDTH	(I_VID_WIDTH	),
		.AXI_DATA_WIDTH (AXI_DATA_WIDTH )
)
  u_bank_sw
(
/*i*/.ddr_clk		(axi_clk	),
/*i*/.rst_n			(axi_clk_rst_n),
              	
/*i*/.wr_sw			(wr_sw),
/*i*/.rd_sw			(rd_sw),
                
/*o*/.wr_bank		(wr_bank	),
/*o*/.rd_bank		(rd_bank	),
/*o*/.rd_sw_ack	(rd_sw_ack),
/*o*/.wr_sw_ack (wr_sw_ack),
/*o*/.rd_start_addr(rd_start_addr),
/*o*/.wr_start_addr(wr_start_addr)
);




endmodule