

module ddr_tx_buffer #(
	parameter O_VID_WIDTH 	= 16 ,   
	parameter AXI_RD_ID  		= 8'ha5,
	parameter AXI_ID_WIDTH	= 8,
	parameter AXI_DDR_WIDTH = 256,
	parameter AXI_BYTE_NUMBER = AXI_DDR_WIDTH/8  ,
	parameter BURST_LEN = 8'd128,
  parameter AXI_DATA_SIZE   = $clog2(AXI_BYTE_NUMBER)

)(
input		wire											wrclk,
input		wire											wrclk_rst_n,
input		wire											rdclk,
input		wire											rdclk_rst_n,
input		wire											tx_ena,
//input		wire	[12:0]							h_width,
//input		wire	[12:0]							v_hight,
input		wire 	[12:0]							H_PRE_PORCH 	,
input		wire 	[12:0]							H_SYNC 				,
input		wire 	[12:0]							H_VALID 			,
input		wire 	[12:0]							H_BACK_PORCH 	,
input		wire 	[12:0]							V_PRE_PORCH 	,
input		wire 	[12:0]							V_SYNC 				,
input		wire 	[12:0]							V_VALID 			,
input		wire 	[12:0]							V_BACK_PORCH 	,

output	reg												bank_sw  = 1'b0,
input		wire											bank_sw_ack,
input		wire	[31:0]							start_addr,
output	reg												rd_addr_error = 1'b0,
output	reg												frame_change = 1'b0,

output	wire 	[O_VID_WIDTH-1:0] 	vout   ,
output	wire											hs_o   ,
output	wire											vs_o   ,
output	wire											de_o   ,
                              		
output  wire	[AXI_ID_WIDTH-1:0] 	ARID   , 
output  wire	[     31:0] 				ARADDR , 
output  wire	[      7:0] 				ARLEN  , 
output  wire	[      2:0] 				ARSIZE , 
output  wire	[      1:0] 				ARBURST, 
output  wire	[      1:0] 				ARLOCK , 
output  wire	            				ARVALID, 
input   wire	            				ARREADY, 
/////////////                 		    
input	  wire	[AXI_ID_WIDTH-1:0] 	RID    , 
input   wire	[      1:0] 				RRESP  , 
input   wire	            				RLAST  , 
input   wire	            				RVALID , 
output  wire	            				RREADY , 
input   wire	[AXI_DDR_WIDTH-1:0] 		RDATA  ,

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

localparam SHIFT_WIDTH = AXI_DDR_WIDTH/O_VID_WIDTH;
localparam AXI_PIXEL_NUM = AXI_DDR_WIDTH/O_VID_WIDTH;
localparam PIXEL_NUM_SIZE   = $clog2(AXI_PIXEL_NUM) ;
localparam BURST_LEN_SIZE = $clog2(BURST_LEN );
//==================================================
//
//==================================================
wire[  8:0] 					wrusedw;
wire							fifo_rd_empty;
wire[AXI_DDR_WIDTH-1:0] 					fifo_rd_data;
reg	[SHIFT_WIDTH-1:0] 					rd_shift = 0;
reg	[AXI_DDR_WIDTH-1:0] 		dout_buf = 0;
reg	[31:0]						rd_addr	 =  'd0;
reg 							addr_en  = 1'b0;
reg	[ 7:0]				ddr_burst_len = 'd0;
wire							addr_add_en;
wire							tx_almost_full		;
reg								rd_shift_period = 1'b0;
reg								rd_shift_en = 1'b0;
wire							tx_valid;
wire	[O_VID_WIDTH-1:0]	 	tx_vin;  
wire	[AXI_DDR_WIDTH-1:0] 	ddr_rd_data  ; 
wire							ddr_rd_valid ;   
wire	[AXI_DDR_WIDTH-1:0] 	fifo_wr_data ;
wire							fifo_wr_en 	 ;
reg [31:0]	frame_len 				= 'd0;
reg	[27:0] 	frame_burst_len		= 'd0;
reg	[23:0]	burst_num_0				= 'd0;
reg	[23:0]	burst_num_1				= 'd0;

reg	[31:0]  last_burst_addr_0 = 'd0;
reg [31:0]  last_burst_addr_1 = 'd0;
reg	[31:0]	last_burst_addr		= 'd0;
reg	[ 7:0]	last_burstcount		= 'd0;
reg					fifo_wr_almost_full	= 1'b0;
reg	[31:0]	r_start_addr			= 'd0;
reg	[1:0] 	wait_cnt = 2'd0;
	reg				rd_cnt_period = 1'b0;
	reg [3:0] state = 4'd0;
	reg				first_ddr_rd = 'd0;
wire		fifo_rd_period;

//==================================================
//                                                  
//==================================================
	
	//after frame info process, enable the state
	reg state_en = 1'b0;
	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n )
				state_en <= 1'b0;
			else
				state_en <= addr_add_en | first_ddr_rd;
	end
	reg	sync_fifo_rd_period0 = 1'b0;
	reg sync_fifo_rd_period1 = 1'b0;
	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n ) begin
					sync_fifo_rd_period0 <= 1'b0;
					sync_fifo_rd_period1 <= 1'b0;
			end else begin
					sync_fifo_rd_period0 <= fifo_rd_period;
					sync_fifo_rd_period1 <= sync_fifo_rd_period0;
			end
	end
	wire neg_fifo_rd_period = ~sync_fifo_rd_period0 & sync_fifo_rd_period1;
	
	
	
	//=====================================================
	
	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n ) 
					state <= 4'd0;
			else if(sync_fifo_rd_period1) begin
					case( state )
					4'd0 : begin
								state <= 4'd1;
					end
					4'd1 : begin
								if( &wait_cnt )
										state <= 4'd2;
					end
					4'd2 : begin
							if(state_en  & fifo_wr_almost_full )
									state <= 4'd3;
							else if( state_en )
									state <= 4'd4;
					end
					4'd3 : begin
							if( ~fifo_wr_almost_full )
									state <= 4'd4;
					end
					4'd4: begin //read en
								state <= 4'd5;
					end
					4'd5 : begin//addr_add 
								state <= 4'd6;
					end
					4'd6 : begin//burst_len_ctrl
								state <= 4'd7;
					end
					4'd7 : begin
								if( bank_sw )
									state <= 4'd8;
								else 
									state <= 4'd2;
					end
					4'd8 : begin
								if( addr_add_en )
										state <= 4'd9;
					end
					4'd9 : begin
//							if( ~bank_sw && rd_data_cnt == frame_burst_len )
//									state <= 4'd0;
								state <= 4'd9;
					end
		
					default:;
					endcase
			end else begin
					state <= 4'd0;
			end
	end
	//�ϵ��һ֡�����֮���ٴμ���֡��Ϣ
	//state == 0
	always @( posedge wrclk )
	begin
					frame_len 	 <= (state == 4'd0) ? H_VALID * V_VALID : frame_len ;
					r_start_addr <= (state == 4'd0) ? start_addr : r_start_addr;
	end
	
	//state == 1
	always @( posedge wrclk )
	begin
			wait_cnt <= (state == 4'd1 ) ? (wait_cnt + 1'b1) : 0;
	end
						
	
	//3 frame info process	

	always @( posedge rdclk )
	begin
		frame_burst_len 	<= frame_len[31:PIXEL_NUM_SIZE] + |frame_len[PIXEL_NUM_SIZE-1:0]; //
		burst_num_0			<= frame_burst_len[27:BURST_LEN_SIZE] ;
		burst_num_1 		<= frame_burst_len[27:BURST_LEN_SIZE]-1 ;
		last_burstcount 	<= |frame_burst_len[BURST_LEN_SIZE-1:0] ? (frame_burst_len[BURST_LEN_SIZE-1:0]-1) : (BURST_LEN-1) ;
		last_burst_addr_0 	<= (burst_num_0<<(AXI_DATA_SIZE+BURST_LEN_SIZE)) + r_start_addr;
		last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+BURST_LEN_SIZE)) + r_start_addr;
		last_burst_addr		<= |frame_burst_len[BURST_LEN_SIZE-1:0] ? last_burst_addr_0 : last_burst_addr_1;
	end 

	/* generate  
	 if(BURST_LEN == 16 ) begin:trans_f 
	         
			always@( posedge rdclk )
			begin 
					frame_burst_len 	<= frame_len[31:4] + |frame_len[3:0]; //
					burst_num_0				<= frame_burst_len[27:4] ;
					burst_num_1 			<= frame_burst_len[27:4]-1 ;
					last_burstcount 	<= |frame_burst_len[3:0] ? (frame_burst_len[3:0]-1) : (BURST_LEN-1'b1);//|frame_len[7:4] ? frame_len[3:0]-1 : 4'd15;
					
					last_burst_addr_0 <= (burst_num_0<<(AXI_DATA_SIZE+4)) + r_start_addr;
					last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+4)) + r_start_addr;
					last_burst_addr		<= |frame_burst_len[3:0] ? last_burst_addr_0 : last_burst_addr_1;
			end
	end else if( BURST_LEN == 64 ) begin
			always@( posedge rdclk )
			begin 
					
					frame_burst_len 	<= frame_len[31:4] + |frame_len[3:0]; //
					burst_num_0				<= frame_burst_len[27:6] ;
					burst_num_1 			<= frame_burst_len[27:6]-1 ;
					last_burstcount 	<= |frame_burst_len[5:0] ? (frame_burst_len[5:0]-1) : (BURST_LEN-1'b1) ;//|frame_len[7:4] ? frame_len[3:0]-1 : 4'd15;
					
					last_burst_addr_0 <= (burst_num_0<<(AXI_DATA_SIZE+6)) + r_start_addr;
					last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+6)) + r_start_addr;
					last_burst_addr		<= |frame_burst_len[5:0] ? last_burst_addr_0 : last_burst_addr_1;	
			end
	end else if( BURST_LEN == 128 ) begin 
					always@( posedge rdclk )
					begin 
							
							frame_burst_len 	<= frame_len[31:4] + |frame_len[3:0]; //
							burst_num_0				<= frame_burst_len[27:7] ;
							burst_num_1 			<= frame_burst_len[27:7]-1 ;
							last_burstcount 	<= |frame_burst_len[6:0] ? (frame_burst_len[6:0]-1) : (BURST_LEN-1) ;//|frame_len[7:4] ? frame_len[3:0]-1 : 4'd15;
							
							last_burst_addr_0 <= (burst_num_0<<(AXI_DATA_SIZE+7)) + r_start_addr;
							last_burst_addr_1	<= (burst_num_1<<(AXI_DATA_SIZE+7)) + r_start_addr;
							last_burst_addr		<= |frame_burst_len[6:0] ? last_burst_addr_0 : last_burst_addr_1;	
					end
	end
	endgenerate	 */
	
	always @( posedge wrclk)
	begin
			if( state == 4'd1 )
						first_ddr_rd <= 1'b1;
			else if( state == 4'd4 )
						first_ddr_rd <= 1'b0;
	end
					
	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n )
					addr_en <= 1'b0;
			else if( state == 4'd4 )
					addr_en <= 1'b1;
			else
					addr_en <= 1'b0;
	end
	
	always @( posedge wrclk or negedge wrclk_rst_n)
	begin
			if( !wrclk_rst_n )
					rd_addr <= start_addr;
			else if( state == 4'd0 )
					rd_addr <= start_addr;
			else if(state == 4'd5 )//( addr_add_en )
					rd_addr  <= rd_addr + AXI_BYTE_NUMBER*(ddr_burst_len+1);
	end  

	//ddr_burst_len
	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n )
					ddr_burst_len <= (BURST_LEN-1'b1);
			else if( state == 4'd0 )//(state == 4'd4)
						ddr_burst_len <= (BURST_LEN-1'b1);
			else if( rd_addr == last_burst_addr && state == 4'd6 )
						ddr_burst_len 	<= last_burstcount;
			
	end
	
	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n )
						bank_sw <= 1'b0;
			else if( rd_addr > last_burst_addr && state == 4'd6)
						bank_sw <= 1'b1;
			else if( bank_sw_ack )
						bank_sw <= 1'b0;
	end
	
	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n )
					rd_cnt_period <=  1'b0;
			else if( state == 4 )
					rd_cnt_period <= 1'b1;
			else if( state == 0 )
					rd_cnt_period <= 1'b0;
					
	end
	

	always @( posedge wrclk or negedge wrclk_rst_n )
	begin
			if( !wrclk_rst_n )
					rd_addr_error <= 1'b0;
			else	if( ARVALID && ARREADY && (ARADDR > last_burst_addr) )
					
					rd_addr_error <= 1'b1;
	end
	
	//=====================================================
	



DdrRdCtrl  #(
	.AXI_RD_ID       (AXI_RD_ID  	 ),
	.AXI_ID_WIDTH		 (AXI_ID_WIDTH),
	.AXI_DATA_WIDTH  (AXI_DDR_WIDTH  )
)
	u_ddr_rd_ctrl
(
  /////////////////////////////////////////////////////////

  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  /*i*/.SysClk    	(wrclk),     //System Clock
  /*i*/.Reset_N   	(wrclk_rst_n ),     //System Reset

  /////////////////////////////////////////////////////////
  //Operate Control & State
  /*i*/.RamRdStart  (addr_en), //(I)[DdrRdCtrl]Ram Read Start
  /*o*/.RamRdEnd    (addr_add_en ), //(O)[DdrRdCtrl]Ram Read End
  /*o*/.RamRdAddr   (		), //(O)[DdrRdCtrl]Ram Read Addrdss
  /*o*/.RamRdDAva   (ddr_rd_valid), //(O)[DdrRdCtrl]Ram Read Available //data_valid
  /*o*/.RamRdBusy   (		), //(O)Ram Read Busy
  /*o*/.RamRdALoad  (		), //(O)Ram Read Address Load
  /*o*/.RamRdData   (ddr_rd_data), //(O)[DdrRdCtrl]Ram Read Data
                    
                    
  /*i*/.CfgRdAddr   (rd_addr), //(I)[DdrRdCtrl]Config Read Start Address
  /*i*/.CfgRdBLen   (ddr_burst_len), //(I)[DdrRdCtrl]Config Read Burst Length


  /*o*/.ARID        (ARID    ), //(I)[RdAddr]Read address ID. This signal is the identification tag for the read address group of signals.
  /*o*/.ARADDR      (ARADDR  ), //(I)[RdAddr]Read address. The read address gives the address of the first transfer in a read burst transaction.
  /*o*/.ARLEN       (ARLEN   ), //(I)[RdAddr]Burst length. This signal indicates the exact number of transfers in a burst.
  /*o*/.ARSIZE      (ARSIZE  ), //(I)[RdAddr]Burst size. This signal indicates the size of each transfer in the burst.
  /*o*/.ARBURST     (ARBURST ), //(I)[RdAddr]Burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
  /*o*/.ARLOCK      (ARLOCK  ), //(I)[RdAddr]Lock type. This signal provides additional information about the atomic characteristics of the transfer.
  /*o*/.ARVALID     (ARVALID ), //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.
  /*i*/.ARREADY     (ARREADY ), //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /*i*/.RID         (RID     ), //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  /*i*/.RRESP       (RRESP   ), //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  /*i*/.RLAST       (RLAST   ), //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  /*i*/.RVALID      (RVALID  ), //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  /*o*/.RREADY      (RREADY  ), //(I)[RdData]Read ready. This signal indicates that the master can accept the read data and response information.
  /*i*/.RDATA       (RDATA   )  //(O)[RdData]Read data.

);


       

always @( posedge wrclk )
begin
		if( wrusedw > 250 )//60)//
				fifo_wr_almost_full <= 1'b1;
		else
				fifo_wr_almost_full <= 1'b0;
end
reg		frame_info_valid = 1'b0;
assign fifo_wr_data = frame_info_valid ? 
{H_PRE_PORCH,H_SYNC,H_VALID,H_BACK_PORCH,V_PRE_PORCH,V_SYNC,V_VALID,V_BACK_PORCH,frame_burst_len[19:0]}: ddr_rd_data;
assign fifo_wr_en 	= ddr_rd_valid | frame_info_valid;

always @( posedge wrclk )
begin
		if( first_ddr_rd && state == 4'd4 )
				frame_info_valid <=  1'b1;
		else
				frame_info_valid <= 1'b0;
end	 	 	  
         

reg [12:0] h_pre_porch  = 13'd100; 
reg [12:0] h_sync 	 		= 13'd100; 
reg [12:0] h_valid 	 	 	= 13'd100; 
reg [12:0] h_back_porch = 13'd100; 
reg [12:0] v_pre_porch  = 13'd100; 
reg [12:0] v_sync 	 		= 13'd100; 
reg [12:0] v_valid 	 	  = 13'd100; 
reg [12:0] v_back_porch = 13'd100; 
reg	[2:0] tx_state = 3'd0;
wire			frame_info_rd	;
reg				tx_frame_over = 1'b0;
reg	[19:0]	tx_frame_burst_len = 'd0;
reg	[19:0]			tx_cnt ='d0;

	DC_FIFO
# (
  	.FIFO_MODE  ( "Normal"    ), //"Normal"; //"ShowAhead"
    .DATA_WIDTH ( AXI_DDR_WIDTH  ),
    .FIFO_DEPTH ( 512         )
  ) u_wr_fifo(   
  //System Signal
  /*i*/.Reset   (~wrclk_rst_n | neg_fifo_rd_period ), //System Reset
  //Write Signal                             
  /*i*/.WrClk   (wrclk), //(I)Wirte Clock
  /*i*/.WrEn    (fifo_wr_en), //(I)Write Enable
  /*o*/.WrDNum  (wrusedw), //(O)Write Data Number In Fifo
  /*o*/.WrFull  (), //(I)Write Full 
  /*i*/.WrData  (fifo_wr_data), //(I)Write Data
  //Read Signal                            
  /*i*/.RdClk   (rdclk), //(I)Read Clock
  /*i*/.RdEn    (fifo_rd_en | frame_info_rd), //(I)Read Enable
  /*o*/.RdDNum  (), //(O)Radd Data Number In Fifo
  /*o*/.RdEmpty (fifo_rd_empty), //(O)Read FifoEmpty
  /*o*/.RdData  (fifo_rd_data)  //(O)Read Data
);

always @( posedge rdclk or negedge rdclk_rst_n )
begin
		if( !rdclk_rst_n )
				tx_state <= 3'd0;
		else if( fifo_rd_period) begin
				case( tx_state )
						3'd0 : begin
								if( frame_info_rd )
									tx_state <= 3'd1;										
						end
						3'd1 : begin
									tx_state <= 3'd2;
						end
						3'd2 : begin
									if( tx_frame_over )
											tx_state <= 3'd3;
						end
						3'd3 : begin
									tx_state <= 3'd3;
						end
						default:;
						endcase
		end else begin
					tx_state <= 3'd0;
		end
end
assign frame_info_rd = (~tx_almost_full)  & ~fifo_rd_empty & ~rd_shift_en & ( tx_state == 3'd0)& fifo_rd_period ;

assign fifo_rd_en = (~tx_almost_full)  & ~fifo_rd_empty & ~rd_shift_en & (tx_state == 3'd2) & (~tx_frame_over) ;

always @( posedge rdclk or negedge rdclk_rst_n )
begin
		if( !rdclk_rst_n ) begin
				h_pre_porch  <=  H_PRE_PORCH ; 
				h_sync 	 		 <=  H_SYNC 	 		;
				h_valid 	 	 <=  H_VALID 	 	 ; 
				h_back_porch <=  H_BACK_PORCH; 
				v_pre_porch  <=  V_PRE_PORCH ; 
				v_sync 	 		 <=  V_SYNC 	 		;
				v_valid 	 	 <=  V_VALID 	 	 ; 
			  v_back_porch <=  V_BACK_PORCH; 
		end else if( tx_state == 3'd1 ) begin
				tx_frame_burst_len[19:0] <= fifo_rd_data[19:0];
				h_pre_porch  <=  fifo_rd_data[123:111]; 
				h_sync 	 		 <=  fifo_rd_data[110:98] ;  
				h_valid 	 	 <=  fifo_rd_data[97:85];	
				h_back_porch <=  fifo_rd_data[84:72]; 
				v_pre_porch  <=  fifo_rd_data[71:59]; 
				v_sync 	 		 <=  fifo_rd_data[58:46]; 
				v_valid 	 	 <=  fifo_rd_data[45:33];
				v_back_porch <=  fifo_rd_data[32:20] ;
		end
end

	always @( posedge rdclk or negedge rdclk_rst_n )
	begin
			if( !rdclk_rst_n ) begin
					frame_change <= 1'b0;
			end else if(tx_state == 3'd1 )begin
					if( h_valid != fifo_rd_data[97:85] || v_valid != fifo_rd_data[45:33])
							frame_change <= 1'b1;
					
			end else begin
					frame_change <= 1'b0;
			end
					
	end

always @( posedge rdclk or negedge rdclk_rst_n )
begin   
		if( !rdclk_rst_n ) begin
				tx_cnt <= 'd0;
				tx_frame_over <= 'd0;
		end else if( tx_state == 3'd2  ) begin
				if( fifo_rd_en ) begin
						if( tx_cnt == tx_frame_burst_len-1 )
								tx_frame_over <= 1'b1;
						else
								tx_cnt <= tx_cnt + 1'b1;
				end else begin
						tx_cnt <= tx_cnt ;
				end
		end else begin
				tx_cnt <= 'd0;   
				tx_frame_over <=  1'b0;
		end
end

always @( posedge rdclk or negedge rdclk_rst_n)
		if( !rdclk_rst_n )
			rd_shift_en <= 1'b0;
		else if( fifo_rd_en )
			rd_shift_en <= 1'b1;
		else if( rd_shift[SHIFT_WIDTH-2] )//16 data shift 15 times
			rd_shift_en <= 1'b0;

always @( posedge rdclk or negedge rdclk_rst_n )
begin
		if( !rdclk_rst_n )
				rd_shift <= 'd0;
		else if( fifo_rd_en ) 
				rd_shift <= 16'd1;
		else
				rd_shift <= {rd_shift[SHIFT_WIDTH-2:0],1'b0};
end

always @( posedge rdclk )
begin
		
		if( rd_shift[0] )
				dout_buf <= fifo_rd_data;
		else
				dout_buf <= {dout_buf[AXI_DDR_WIDTH-O_VID_WIDTH-1:0],{O_VID_WIDTH{1'd0}}};
end

always @( posedge rdclk )
begin
		rd_shift_period <= |rd_shift;
end
assign tx_valid = rd_shift_period;
assign tx_vin = dout_buf[AXI_DDR_WIDTH-1:AXI_DDR_WIDTH-O_VID_WIDTH];
//reg	tx_frame_en = 1'b0;
//always @( posedge rdclk or negedge rdclk_rst_n )
//begin
//		if( !rdclk_rst_n )
//					tx_frame_en <= 1'b0;
//		else if( ~fifo_rd_empty )
//					tx_frame_en <= 1'b1;
//end

wire [6:0] ascii;
wire [511:0] char_data;

data_tx #(
	.VID_WIDTH 				( O_VID_WIDTH  ),
	.FIFO_DIPTH  			( 512 				 ),
	.FIFO_ALMOST_FULL	( 450   )//(120					 )
	
	
	)u_data_tx(
	/*i*/.clk					(rdclk				),
	/*i*/.rst_n				(rdclk_rst_n	),
	/*i*/.H_PRE_PORCH (h_pre_porch  ),//( 50 			),
	/*i*/.H_SYNC 	 		(h_sync 	 		),//( 50 			),
	/*i*/.H_VALID 	 	(h_valid 	 	  ),//( 48 			),
	/*i*/.H_BACK_PORCH(h_back_porch ),//( 50 			),
	/*i*/.V_PRE_PORCH (v_pre_porch  ),//( 5 			),
	/*i*/.V_SYNC 	 		(v_sync 	 		),//( 5 			),
	/*i*/.V_VALID 	 	(v_valid 	 	  ),//( 20 			),
	/*i*/.V_BACK_PORCH(v_back_porch ),//( 5 			),
	/*i*/.frame_en		( 1'b1 				),//(tx_frame_en	),
	/*i*/.fifo_wr_data(tx_vin				),
	/*i*/.fifo_wr_en	(tx_valid			),
	/*o*/.fifo_wr_almost_full	(tx_almost_full	),
	/*o*/.fifo_rd_period(fifo_rd_period),
	/*o*/.vout		(vout		),
	/*o*/.hs_o		(hs_o		),
	/*o*/.vs_o		(vs_o		),
	/*o*/.de_o		(de_o		),

	.char_data      (char_data),
    .ascii          (ascii),
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


ram_char ram_char (
/*i*/.raddr	(ascii),
/*o*/.rdata (char_data)
);

endmodule
