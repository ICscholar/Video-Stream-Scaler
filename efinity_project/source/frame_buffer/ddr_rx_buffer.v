

module ddr_rx_buffer #(
	parameter  I_VID_WIDTH = 16,
	parameter  AXI_DDR_WIDTH = 256,
	parameter	 AXI_WR_ID	 	= 8'ha0,
	parameter  AXI_ID_WIDTH = 8,
	parameter  BURST_LEN = 8'd128,
	parameter  AXI_BYTE_NUMBER = AXI_DDR_WIDTH/8  ,
  parameter  AXI_DATA_SIZE   = $clog2(AXI_BYTE_NUMBER) 	
)(
input		wire													wrclk,
input		wire													wrclk_rst_n,
input		wire													rdclk,
input		wire													rdclk_rst_n,
input		wire													i_vs,
input		wire													i_de,
input		wire	[I_VID_WIDTH-1:0] 			vin,  

output	reg													bank_sw  = 1'b0,
input		wire											bank_sw_ack,
input		wire	[31:0]									start_addr,

output 	wire						  						fifo_wr_overflow ,

output  		[AXI_ID_WIDTH-1:0]    		AWID        ,
output  		[31:0]    								AWADDR			,
output  	 	[ 7:0]   								AWLEN   		,
output  		[ 2:0]    								AWSIZE      ,
output  		[ 1:0]    								AWBURST     ,
output  		[ 1:0]    								AWLOCK      ,
output   	      										AWVALID     ,
input             										AWREADY     ,
/////////////               							   
output  	[AXI_ID_WIDTH-1:0]    			WID         ,
output		[AXI_BYTE_NUMBER-1:0] 			WSTRB       ,
output            										WLAST       ,
output            										WVALID      ,
input             										WREADY      ,
output		[AXI_DDR_WIDTH-1:0] 				WDATA       ,
/////////////               							   
input   	[AXI_ID_WIDTH-1:0]    			BID         ,
input             										BVALID      ,
output            										BREADY       


);
//================================================================
//
//================================================================
localparam AXI_PIXEL_NUM = AXI_DDR_WIDTH/I_VID_WIDTH;
localparam PIXEL_NUM_SIZE   = $clog2(AXI_PIXEL_NUM) ;
localparam BURST_LEN_SIZE = $clog2(BURST_LEN );

  wire			[ 11:0] 	fifo_rdusedw;
  wire							fifo_wr_en;
  wire	[AXI_DDR_WIDTH-1:0]	fifo_wr_data;    
  wire	[AXI_DDR_WIDTH-1:0]	fifo_rd_data;

  wire							frame_start;
  
  reg								ddr_wr_en = 1'b0;
  reg 			 [1:0]		state = 2'b00;
  reg				[31:0]		ddr_addr = 'd0		;
  reg				[ 7:0]		ddr_burst_len = 0;
  reg								burst_start = 1'b0;  
  wire							burst_1st_rd	;  
  wire							burst_2ed_rd	; 
  reg								fifo_rd_valid	;
  wire							addr_add		;
  reg 							frame_start_sync0 = 1'b0;
  reg 							frame_start_sync1 = 1'b0;  
  reg								frame_start_sync2 = 1'b0;
  wire							fifo_rst	;  
  wire							pos_frame_start_sync;  
  wire							frame_end		;
  reg		[31:0]			r_start_addr	= 'd0;
  reg 	[31:0]		frame_len 				= 'd0;
  wire	[31:0]		frame_cnt					;
	reg		[27:0] 		frame_burst_len		= 'd0;
	reg		[23:0]		burst_num_0				= 'd0;
	reg		[23:0]		burst_num_1				= 'd0;
	    	        	
	reg		[31:0]  	last_burst_addr_0 = 'd0;
	reg 	[31:0]  	last_burst_addr_1 = 'd0;
	reg		[31:0]		last_burst_addr		= 'd0;
	reg		[ 7:0]		last_burstcount		= 'd0;
  
	
  wire						fifo_wr_full					;
  
  vid_rx_align #(
	.I_VID_WIDTH   (I_VID_WIDTH		),
	.AXI_DDR_WIDTH (AXI_DDR_WIDTH )
)u_vid_rx_align(
/*i*/.clk			(wrclk			),  
/*i*/.rst_n			(wrclk_rst_n	),
/*i*/.i_vs			(i_vs			), //active hgih
/*i*/.i_de			(i_de			), //active high
/*i*/.vin			(vin			),
/*o*/.fifo_wr_en	(fifo_wr_en		),
/*o*/.fifo_wr_data	(fifo_wr_data	),
/*o*/.frame_start	(frame_start	),
/*O*/.fifo_rst		(fifo_rst		),
/*o*/.frame_cnt   	(	frame_cnt 	)
);
 
 assign fifo_wr_overflow =  fifo_wr_full & fifo_wr_en;
 

 

	DC_FIFO
# (
  	.FIFO_MODE  ( "Normal"    ), //"Normal"; //"ShowAhead"
    .DATA_WIDTH ( AXI_DDR_WIDTH),
    .FIFO_DEPTH ( 2048        )
  ) u_wr_fifo(   
  //System Signal
  /*i*/.Reset   (fifo_rst	| ~wrclk_rst_n), //System Reset
  //Write Signal                             
  /*i*/.WrClk   (wrclk				), //(I)Wirte Clock
  /*i*/.WrEn    (fifo_wr_en		), //(I)Write Enable
  /*o*/.WrDNum  (fifo_wrusedw	), //(O)Write Data Number In Fifo
  /*o*/.WrFull  (fifo_wr_full ), //(I)Write Full 
  /*i*/.WrData  (fifo_wr_data ), //(I)Write Data
  //Read Signal                            
  /*i*/.RdClk   (rdclk				), //(I)Read Clock
  /*i*/.RdEn    (fifo_rd_en		), //(I)Read Enable
  /*o*/.RdDNum  (fifo_rdusedw	), //(O)Radd Data Number In Fifo
  /*o*/.RdEmpty (fifo_rd_empty), //(O)Read FifoEmpty
  /*o*/.RdData  (fifo_rd_data	)  //(O)Read Data
);
	assign fifo_rd_en = burst_1st_rd | burst_2ed_rd;     
	
	
	
	always @( posedge rdclk )
	begin
			fifo_rd_valid <= fifo_rd_en;
	end
	reg	ddr_wr_en_r = 1'b0;
	always @( posedge rdclk or negedge rdclk_rst_n )
	begin
			if( ~rdclk_rst_n ) 
					ddr_wr_en <= 1'b0;
			else if( (fifo_rdusedw > ddr_burst_len) && ~fifo_rd_empty )
					ddr_wr_en <= 1'b1;
			else
					ddr_wr_en <= 1'b0;			
	end
	
	
	always @( posedge rdclk or negedge rdclk_rst_n )
	begin
			if( ~rdclk_rst_n ) begin
			    frame_start_sync0 <= 'd0;
			    frame_start_sync1 <= 'd0;
			    frame_start_sync2 <= 'd0;
			end else begin
					frame_start_sync0 <= frame_start;
					frame_start_sync1 <= frame_start_sync0;		 
					frame_start_sync2 <= frame_start_sync1;
			end
	end                    
	
	assign pos_frame_start_sync = (~frame_start_sync2) & frame_start_sync1;
	
	//
	
	
	always @( posedge rdclk or negedge rdclk_rst_n )
			if( ~rdclk_rst_n )
					r_start_addr <= start_addr;
			else
					r_start_addr <= frame_end  ? start_addr : r_start_addr;//(| fifo_rst)
	
	always @( posedge rdclk )
		frame_len <= frame_cnt;

	always @(posedge rdclk )
		frame_burst_len 	<= frame_len[31:PIXEL_NUM_SIZE] + |frame_len[PIXEL_NUM_SIZE-1:0]; //

	always @( posedge rdclk )
	begin
		burst_num_0			<= frame_burst_len[27:BURST_LEN_SIZE] ;
		burst_num_1 		<= frame_burst_len[27:BURST_LEN_SIZE]-1 ;
		last_burstcount 	<= |frame_burst_len[BURST_LEN_SIZE-1:0] ? (frame_burst_len[BURST_LEN_SIZE-1:0]-1) : (BURST_LEN-1) ;
		last_burst_addr_0 	<= (burst_num_0<<(AXI_DATA_SIZE+BURST_LEN_SIZE)) + r_start_addr;
		last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+BURST_LEN_SIZE)) + r_start_addr;
		last_burst_addr		<= |frame_burst_len[BURST_LEN_SIZE-1:0] ? last_burst_addr_0 : last_burst_addr_1;
	end 
 
	/*  generate  
	 if(BURST_LEN == 16 ) begin:trans_f 
	         
			always@( posedge rdclk )
			begin 
				//	frame_burst_len 	<= frame_len[31:4] + |frame_len[3:0]; //
					burst_num_0				<= frame_burst_len[27:4] ;
					burst_num_1 			<= frame_burst_len[27:4]-1 ;
					last_burstcount 	<= |frame_burst_len[3:0] ? (frame_burst_len[3:0]-1) : (BURST_LEN-1) ;//
					
					last_burst_addr_0 <= (burst_num_0<<(AXI_DATA_SIZE+4)) + r_start_addr;
					last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+4)) + r_start_addr;
					last_burst_addr		<= |frame_burst_len[3:0] ? last_burst_addr_0 : last_burst_addr_1;
			end
	end else if( BURST_LEN == 64 ) begin
			always@( posedge rdclk )
			begin 
					
				//	frame_burst_len 	<= frame_len[31:4] + |frame_len[3:0]; //
					burst_num_0				<= frame_burst_len[27:6] ;
					burst_num_1 			<= frame_burst_len[27:6]-1 ;
					last_burstcount 	<= |frame_burst_len[5:0] ? (frame_burst_len[5:0]-1) : (BURST_LEN-1) ;//|frame_len[7:4] ? frame_len[3:0]-1 : 4'd15;
					
					last_burst_addr_0 <= (burst_num_0<<(AXI_DATA_SIZE+6)) + r_start_addr;
					last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+6)) + r_start_addr;
					last_burst_addr		<= |frame_burst_len[5:0] ? last_burst_addr_0 : last_burst_addr_1;	
			end
	end else if( BURST_LEN == 128 ) begin 
				always@( posedge rdclk )
				begin 
						
					//	frame_burst_len 	<= frame_len[31:4] + |frame_len[3:0]; //
						burst_num_0				<= frame_burst_len[27:7] ;
						burst_num_1 			<= frame_burst_len[27:7]-1 ;
						last_burstcount 	<= |frame_burst_len[6:0] ? (frame_burst_len[6:0]-1) : (BURST_LEN-1) ;//|frame_len[7:4] ? frame_len[3:0]-1 : 4'd15;
						
						last_burst_addr_0 <= (burst_num_0<<(AXI_DATA_SIZE+7)) + r_start_addr;
						last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+7)) + r_start_addr;
						last_burst_addr		<= |frame_burst_len[6:0] ? last_burst_addr_0 : last_burst_addr_1;	
				end
	end
	endgenerate	 */
	
	//set the address to orignal address
	always @( posedge rdclk or negedge rdclk_rst_n )
	begin       
			if( ~rdclk_rst_n )
					ddr_addr <= r_start_addr;
			else if( pos_frame_start_sync )
					ddr_addr <= r_start_addr;
			else if( addr_add )//( burst_2ed_rd )
					ddr_addr 	<= ddr_addr + AXI_BYTE_NUMBER*(ddr_burst_len+1);
	end
	reg	burst_count_flag = 1'b0;
	always @( posedge rdclk )
			burst_count_flag <= addr_add;
	
	
	always @( posedge rdclk )
	begin
			if( pos_frame_start_sync )
					ddr_burst_len 	<= BURST_LEN-1;
			else if( ddr_addr == last_burst_addr && burst_count_flag )
					ddr_burst_len 	<= last_burstcount;
	end
	
	always @( posedge rdclk or negedge rdclk_rst_n )
	begin
			if( ~rdclk_rst_n ) begin
					burst_start <= 1'b0;
					state			<= 2'd0;
			end else begin	
					burst_start <= 1'b0;
					case( state )
					2'b00 : begin
							state 			<= ddr_wr_en ? 2'b01 : state;
							burst_start <= ddr_wr_en ? 1'b1:1'b0;
					end
					2'b01 : 
							state 			<= 2'b10;
					2'b10 : 
							state 			<= (WLAST & WVALID) ? 2'b11 : 2'b10;
					2'b11: 		
							state 			<= 2'b00;
					default:;
					endcase
			
			end
	end
	
	always @( posedge rdclk )
	begin
			if( ddr_addr > last_burst_addr && burst_count_flag )
					bank_sw <= 1'b1;
			else if( bank_sw_ack )
					bank_sw <= 1'b0;
	end
	
	reg bank_sw_d0 = 1'b0;

always @( posedge rdclk or negedge rdclk_rst_n )
begin
		if( ~rdclk_rst_n )
				bank_sw_d0 <= 1'b0;
	 else 
				bank_sw_d0 <= bank_sw;
				
end
assign frame_end = bank_sw_d0 & ~bank_sw; 

	
	
	 DdrWrCtrl #(
	.AXI_WR_ID       ( AXI_WR_ID  	)     ,
	.AXI_DATA_WIDTH  ( AXI_DDR_WIDTH    ),
	.AXI_ID_WIDTH		 (AXI_ID_WIDTH			)         

)u_ddr_wr_ctrl
(
  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  /*i*/.clk    		(rdclk	),     //System Clock
  /*i*/.rst_n   	(rdclk_rst_n	),     //System Reset

  /////////////////////////////////////////////////////////
  //Operate Control & State
  /*i*/.burst_start (burst_start ), //(I)[DdrWrCtrl]Ram Operate Start
  /*o*/.RamWrEnd    (addr_add	 		),//(O)[DdrWrCtrl]Ram Operate End
  /*o*/.RamWrNext   (burst_2ed_rd), //(O)[DdrWrCtrl]Ram Write Next
  /*i*/.RamWrData   (fifo_rd_data), //(I)[DdrWrCtrl]Ram Write Data
  /*o*/.RamWrALoad  (burst_1st_rd), //(O)Ram Write Address Load

  /////////////////////////////////////////////////////////
  /*i*/.addr_i   		(ddr_addr	 ), //(I)[DdrWrCtrl]Config Write Start Address
  /*i*/.burst_len_i (ddr_burst_len	 ), //(I)[DdrWrCtrl]Config Write Burst Length
  /*o*/.AWID        (AWID        ), //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  /*o*/.AWADDR			(AWADDR		 	 ), //(O)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  /*o*/.AWLEN   		(AWLEN   	 	 ), //(O)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
  /*o*/.AWSIZE      (AWSIZE      ), //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  /*o*/.AWBURST     (AWBURST     ), //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  /*o*/.AWLOCK      (AWLOCK      ), //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  /*o*/.AWVALID     (AWVALID     ), //(O)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
  /*i*/.AWREADY     (AWREADY     ), //(I)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /*o*/.WID         (WID         ), //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  /*o*/.WSTRB       (WSTRB       ), //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  /*o*/.WLAST       (WLAST       ), //(O)[WrData]Write last. This signal indicates the last transfer in a write burst.
  /*o*/.WVALID      (WVALID      ), //(O)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  /*i*/.WREADY      (WREADY      ), //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.
  /*o*/.WDATA       (WDATA       ), //(I)[WrData]Write data.
  /*i*/.BID         (BID         ), //(I)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  /*i*/.BVALID      (BVALID      ), //(I)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
  /*o*/.BREADY      (BREADY      )  //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

);
	
endmodule
