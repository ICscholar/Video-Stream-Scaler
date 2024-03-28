
	module data_tx #(
			parameter VID_WIDTH 	= 16,
			parameter FIFO_DIPTH 	= 512,
			parameter FIFO_ALMOST_FULL = 240//fifo_almost_full
			
	)(
	input		wire											clk,
	input		wire											rst_n,
	input		wire											frame_en,
	input		wire	[VID_WIDTH-1:0] 		fifo_wr_data,
	input		wire											fifo_wr_en,
	output	reg												fifo_wr_almost_full, 
	output	reg												fifo_rd_period,     
	output	reg												fifo_rd_underflow,
	
	input		wire 	[12:0]							H_PRE_PORCH 	,
	input		wire 	[12:0]							H_SYNC 				,
	input		wire 	[12:0]							H_VALID 			,
	input		wire 	[12:0]							H_BACK_PORCH 	,
	input		wire 	[12:0]							V_PRE_PORCH 	,
	input		wire 	[12:0]							V_SYNC 				,
	input		wire 	[12:0]							V_VALID 			,
	input		wire 	[12:0]							V_BACK_PORCH 	,
	
	
	output	reg 	[VID_WIDTH-1:0] 		vout,
	output	reg												hs_o,
	output	reg												vs_o,
	output	reg												de_o,

    input        [511:0] char_data,
    output  wire [6:0]   ascii,
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
//==========================================================
//
//==========================================================
localparam WHITE  = 16'heb80;  //RGB888 ��ɫ
localparam BLACK  = 16'h1080;  //RGB888 ��ɫ
localparam CHAR_WIDTH  = 6'd16;     //�ַ�����
localparam CHAR_HEIGHT = 6'd32;     //�ַ��߶�

	localparam S_H_SYNC 				= 2'd0;
	localparam S_H_BACK_PORCH 	= 2'd1;
	localparam S_H_VALID 				= 2'd2;
	localparam S_H_PRE_PORCH 		= 2'd3;
	localparam S_V_SYNC 				= 2'd0;
	localparam S_V_BACK_PORCH 	= 2'd1;
	localparam S_V_VALID 				= 2'd2;
	localparam S_V_PRE_PORCH 		= 2'd3;
	
	wire									fifo_wr_rst ;
	wire	[8:0] 					wrusedw;
	//wire 
	wire	[VID_WIDTH-1:0] fifo_rd_data;
	reg										fifo_rd_en = 1'b0;
	wire									fifo_rd_empty;
	reg	[1:0] 						h_state = S_H_PRE_PORCH;
	reg	[1:0] 						v_state = S_V_PRE_PORCH;
	reg	[12:0] 						h_cnt = 0;
	reg	[12:0] 						v_cnt = 0;
	reg										hs_r1 = 1'b0;
	reg										hs_r2 = 1'b0;
	reg 									vs_r1 = 1'b0;
	reg										vs_r2 = 1'b0;
	reg										de_r1 = 1'b0;
	reg										de_r2 = 1'b0;
	reg										frame_start_d0 = 1'b0;
	reg										frame_start_d1 = 1'b0;
	wire									pos_frame_start;
	reg										frame_ena			 = 1'b0;
	reg										h_pre_porch_flag 	= 1'b0;
	reg										h_sync_flag				= 1'b0;
	reg										h_valid_flag			= 1'b0;
	reg										h_back_porch_flag = 1'b0;
	    									
	reg										v_pre_porch_flag 	= 1'b0;
	reg										v_sync_flag				= 1'b0;
	reg										v_valid_flag			= 1'b0;
	reg										v_back_porch_flag = 1'b0;
	wire									fifo_rst					;
	wire									neg_fifo_rd_period;
//==========================================================
//
//==========================================================
	
	always @( posedge clk )
	begin
			if( wrusedw >= FIFO_ALMOST_FULL ) begin
					fifo_wr_almost_full <= 1'b1;
			end else begin
					fifo_wr_almost_full <= 1'b0;
			end
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( !rst_n ) begin
					frame_start_d0 <= 1'b0;
					frame_start_d1 <= 1'b0;
			end else begin
					frame_start_d0 <= frame_en;
					frame_start_d1 <= frame_start_d0;
			end
	end
	assign pos_frame_start = frame_start_d0 & ~frame_start_d1;
	assign fifo_wr_rst = pos_frame_start | fifo_rst;//fifo_rst_p |
	
	always @( posedge clk or negedge rst_n	)
	begin
			if( ~rst_n )
					frame_ena <= 1'b0;
			else
					frame_ena <= frame_start_d1;
			
	end
	
DC_FIFO
# (
  	.FIFO_MODE  ( "Normal"        	), //"Normal"; //"ShowAhead"
    .DATA_WIDTH ( VID_WIDTH        ),
    .FIFO_DEPTH ( FIFO_DIPTH        )//,

  ) u_rd_fifo(   
  //System Signal
  /*i*/.Reset   (fifo_wr_rst), //System Reset
  //Write Signal                             
  /*i*/.WrClk   (clk), //(I)Wirte Clock
  /*i*/.WrEn    (fifo_wr_en), //(I)Write Enable
  /*o*/.WrDNum  (wrusedw), //(O)Write Data Number In Fifo
  /*o*/.WrFull  (), //(I)Write Full 
  /*i*/.WrData  (fifo_wr_data), //(I)Write Data
  //Read Signal                            
  /*i*/.RdClk   (clk), //(I)Read Clock
  /*i*/.RdEn    (fifo_rd_en), //(I)Read Enable
  /*o*/.RdDNum  (), //(O)Radd Data Number In Fifo
  /*o*/.RdEmpty (fifo_rd_empty), //(O)Read FifoEmpty
  /*o*/.RdData  (fifo_rd_data)  //(O)Read Data
);               

always @( posedge clk or negedge rst_n )
begin
		if( !rst_n )
				fifo_rd_underflow <= 1'b0;    
		else if( pos_frame_start )
				fifo_rd_underflow <= 1'b0;
		else if( fifo_rd_empty & fifo_rd_en )
				fifo_rd_underflow <= 1'b1;
end


//=========================================================
//
//=========================================================
	
	
	always @( posedge clk or negedge rst_n)
	begin
			if( !rst_n )
					  h_pre_porch_flag <= 1'b0;
			else if( !frame_ena)
						h_pre_porch_flag <= 1'b0;
			else if( h_cnt == H_PRE_PORCH -2 )
						h_pre_porch_flag <= 1'b1;
			else
						h_pre_porch_flag <= 1'b0;
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( !rst_n )
						h_sync_flag <= 1'b0;
			else if( !frame_ena )
						h_sync_flag <= 1'b0;
			else if( h_cnt == H_SYNC -2 )
						h_sync_flag <= 1'b1;
			else
						h_sync_flag <= 1'b0;
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( !rst_n )
						h_valid_flag <= 1'b0;
			else if( !frame_ena )
						h_valid_flag <= 1'b0;
			else if( h_cnt == H_VALID -2 )
						h_valid_flag <= 1'b1;
			else
						h_valid_flag <= 1'b0;
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( !rst_n )
						h_back_porch_flag <= 1'b0;
			else if( !frame_ena )
						h_back_porch_flag <= 1'b0;
			else if( h_cnt == H_BACK_PORCH -2 )
						h_back_porch_flag <= 1'b1;
			else
						h_back_porch_flag <= 1'b0;
	end
	
	

	always @( posedge clk or negedge rst_n )
	begin
			if( ~rst_n ) begin
					h_cnt <= 'd0;
					h_state <= S_H_SYNC;
			end else if( frame_ena ) begin
					case(h_state )
					S_H_SYNC : begin
							if( h_sync_flag ) begin
									h_cnt <= 0;
									h_state <= S_H_BACK_PORCH;
							end else begin
									h_cnt <= h_cnt + 1'b1;
							end
					end
					S_H_BACK_PORCH : begin
							if( h_back_porch_flag ) begin
									h_cnt <= 0;
									h_state <= S_H_VALID;
							end else begin
									h_cnt <= h_cnt + 1'b1;
							end
					end
					
					
					S_H_VALID : begin
							if( h_valid_flag ) begin
									h_cnt <= 0;
									h_state <= S_H_PRE_PORCH;
							end else begin
									h_cnt <= h_cnt + 1'b1;
							end
					end
					S_H_PRE_PORCH : begin
									if( h_pre_porch_flag ) begin
											h_cnt <= 0;
											h_state <= S_H_SYNC;
									end else begin
											h_cnt <= h_cnt + 1'b1;
									end
					end
					
					default: begin
							h_state <= S_H_SYNC;
							h_cnt <= 'd0;
					end
					endcase
			end else begin
					h_cnt <= 'd0;
					h_state <= S_H_SYNC;
			end
	end            
	
	always @( posedge clk or negedge rst_n )
	begin
			if( !rst_n )
					v_pre_porch_flag <= 1'b0;
			else if(!frame_ena )
					v_pre_porch_flag <= 1'b0;
			else if( v_cnt == V_PRE_PORCH - 1  )
					v_pre_porch_flag <= 1'b1;
			else
					v_pre_porch_flag <= 1'b0;		
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( !rst_n )
					v_sync_flag <= 1'b0;
			else if(!frame_ena )
					v_sync_flag <= 1'b0;
			else if( v_cnt == V_SYNC - 1  )
					v_sync_flag <= 1'b1;
			else
					v_sync_flag <= 1'b0;		
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( !rst_n )
						v_valid_flag <=  1'b0;
			else if(!frame_ena )
						v_valid_flag <=  1'b0;			
			else if( v_cnt == V_VALID -1  )
						v_valid_flag <= 1'b1;
			else
						v_valid_flag <= 1'b0;
	end
	
	always @( posedge clk or negedge rst_n)
	begin
			if( !rst_n )
						v_back_porch_flag <= 1'b0;
			else if(!frame_ena )
						v_back_porch_flag <= 1'b0;	
			else if( v_cnt == V_BACK_PORCH -1  )
						v_back_porch_flag <= 1'b1;
			else
						v_back_porch_flag <= 1'b0;
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( ~rst_n ) begin
					v_cnt <= 'd0;
					v_state <= S_V_SYNC;	
			end else if( frame_ena ) begin
						case(v_state )
						S_V_SYNC : begin
								if( h_pre_porch_flag && h_state == S_H_PRE_PORCH ) begin
										if( v_sync_flag ) begin
												v_cnt <= 0;
												v_state <= S_V_BACK_PORCH;
										end else begin
												v_cnt <= v_cnt + 1'b1;
										end
								end
						end
						S_V_BACK_PORCH : begin
								if( h_pre_porch_flag && h_state == S_H_PRE_PORCH ) begin
										if( v_back_porch_flag ) begin
												v_cnt <= 0;
												v_state <= S_V_VALID;
										end else begin
												v_cnt <= v_cnt + 1'b1;
										end
								end
						end
						
						
						S_V_VALID : begin
								if( h_pre_porch_flag && h_state == S_H_PRE_PORCH ) begin
										if( v_valid_flag ) begin
												v_cnt <= 0;
												v_state <= S_V_PRE_PORCH;
										end else begin
												v_cnt <= v_cnt + 1'b1;
										end
								end
						end
						S_V_PRE_PORCH : begin
								if( h_pre_porch_flag && h_state == S_H_PRE_PORCH ) begin   
										if(v_pre_porch_flag ) begin
												v_cnt <= 0;
												v_state <= S_V_SYNC;
										end else begin
												v_cnt <= v_cnt + 1'b1;
										end
								end
						end
						default: begin
								v_state <= S_V_SYNC;
								v_cnt <= 'd0;
						end
						endcase
			end else begin
					v_cnt <= 'd0;
					v_state <= S_V_SYNC;	
			end
	end

	always @( posedge clk )
	begin
			if( h_state == S_H_VALID && v_state == S_V_VALID ) begin
					fifo_rd_en <= 1'b1;
			end else begin
					fifo_rd_en <= 1'b0;
			end
	end

reg [VID_WIDTH-1:0] h_cnt_reg,h_cnt_reg1;
always @( posedge clk )
begin
    h_cnt_reg <= h_cnt;
    h_cnt_reg1 <= h_cnt_reg;
end

reg [VID_WIDTH-1:0] v_cnt_reg,v_cnt_reg1;
always @( posedge clk )
begin
    v_cnt_reg <= v_cnt;
    v_cnt_reg1 <= v_cnt_reg;
end

reg [6:0] string[29:1];

// char
wire [15:0] inx = end_x - start_x;
wire [15:0] iny = end_y - start_y;
// wire [3:0]  blank
wire [6:0]  up_x1 = (inx / 1000) % 10;
wire [6:0]  up_x2 = (inx / 100 ) % 10;
wire [6:0]  up_x3 = (inx / 10  ) % 10;
wire [6:0]  up_x4 = (inx 	   ) % 10;
wire [6:0]  up_y1 = (iny / 1000) % 10;
wire [6:0]  up_y2 = (iny / 100 ) % 10;
wire [6:0]  up_y3 = (iny / 10  ) % 10;
wire [6:0]  up_y4 = (iny 	   ) % 10;
wire [6:0]  hdisp_x1 = (H_VALID / 1000) % 10;
wire [6:0]  hdisp_x2 = (H_VALID / 100 ) % 10;
wire [6:0]  hdisp_x3 = (H_VALID / 10  ) % 10;
wire [6:0]  hdisp_x4 = (H_VALID		  ) % 10;
wire [6:0]  vdisp_y1 = (V_VALID / 1000) % 10;
wire [6:0]  vdisp_y2 = (V_VALID / 100 ) % 10;
wire [6:0]  vdisp_y3 = (V_VALID / 10  ) % 10;
wire [6:0]  vdisp_y4 = (V_VALID 	  ) % 10;
wire [6:0]  down_x1 = (size_x / 1000) % 10;
wire [6:0]  down_x2 = (size_x / 100 ) % 10;
wire [6:0]  down_x3 = (size_x / 10  ) % 10;
wire [6:0]  down_x4 = (size_x 		) % 10;
wire [6:0]  down_y1 = (size_y / 1000) % 10;
wire [6:0]  down_y2 = (size_y / 100 ) % 10;
wire [6:0]  down_y3 = (size_y / 10  ) % 10;
wire [6:0]  down_y4 = (size_y 		) % 10;

assign ascii = string[h_cnt_reg1/CHAR_WIDTH+1];

always @(posedge clk) begin
	if( ~rst_n ) begin
		string[ 1] = 7'd1;
		string[ 2] = 7'd9;
		string[ 3] = 7'd2;
		string[ 4] = 7'd0;
		string[ 5] = 7'd13; // x
		string[ 6] = 7'd1;
		string[ 7] = 7'd0;
		string[ 8] = 7'd8;
		string[ 9] = 7'd0;
		string[10] = 7'd11; // -
		string[11] = 7'd12; // >
		string[12] = 7'd1;
		string[13] = 7'd9;
		string[14] = 7'd2;
		string[15] = 7'd0;
		string[16] = 7'd13; // x
		string[17] = 7'd1;
		string[18] = 7'd0;
		string[19] = 7'd8;
		string[20] = 7'd0;
        
		string[21] = 7'd10; // bilinear
		string[22] = 7'd15;
		string[23] = 7'd19;
		string[24] = 7'd20;
		string[25] = 7'd19;
		string[26] = 7'd21;
		string[27] = 7'd16;
		string[28] = 7'd14;
		string[29] = 7'd23;
        
//		string[21] = 7'd10; // neighbor
//		string[22] = 7'd21;
//		string[23] = 7'd16;
//		string[24] = 7'd19;
//		string[25] = 7'd17;
//		string[26] = 7'd18;
//		string[27] = 7'd15;
//		string[28] = 7'd22;
//		string[29] = 7'd13;
	end
	if(param_valid) begin
		case(packet_type[3:0])	
			4'd0 : begin // up
				string[ 1] = up_x1;
				string[ 2] = up_x2;
				string[ 3] = up_x3;
				string[ 4] = up_x4;
				string[ 5] = 7'd13; // x
				string[ 6] = up_y1;
				string[ 7] = up_y2;
				string[ 8] = up_y3;
				string[ 9] = up_y4;
				string[10] = 7'd11; // -
				string[11] = 7'd12; // >
				string[12] = hdisp_x1;
				string[13] = hdisp_x2;
				string[14] = hdisp_x3;
				string[15] = hdisp_x4;
				string[16] = 7'd13; // x
				string[17] = vdisp_y1;
				string[18] = vdisp_y2;
				string[19] = vdisp_y3;
				string[20] = vdisp_y4;
			end 
			4'd1 : begin // down
				string[ 1] = hdisp_x1;
				string[ 2] = hdisp_x2;
				string[ 3] = hdisp_x3;
				string[ 4] = hdisp_x4;
				string[ 5] = 7'd13; // x
				string[ 6] = vdisp_y1;
				string[ 7] = vdisp_y2;
				string[ 8] = vdisp_y3;
				string[ 9] = vdisp_y4;
				string[10] = 7'd11; // -
				string[11] = 7'd12; // >
				string[12] = down_x1;
				string[13] = down_x2;
				string[14] = down_x3;
				string[15] = down_x4;
				string[16] = 7'd13; // x
				string[17] = down_y1;
				string[18] = down_y2;
				string[19] = down_y3;
				string[20] = down_y4;
			end 
			default: ;
		endcase
        
		case(Algorithm[0])	
			4'd0 : begin
                string[21] = 7'd10; // bilinear
                string[22] = 7'd15;
                string[23] = 7'd19;
                string[24] = 7'd20;
                string[25] = 7'd19;
                string[26] = 7'd21;
                string[27] = 7'd16;
                string[28] = 7'd14;
                string[29] = 7'd23;
			end 
			4'd1 : begin
                string[21] = 7'd10; // neighbor
                string[22] = 7'd21;
                string[23] = 7'd16;
                string[24] = 7'd19;
                string[25] = 7'd17;
                string[26] = 7'd18;
                string[27] = 7'd15;
                string[28] = 7'd22;
                string[29] = 7'd23;
			end 
			default: ;
		endcase
	end
end

	always @( posedge clk )
	begin
	    if((v_cnt_reg1 >= 0) && (v_cnt_reg1 < CHAR_HEIGHT) && (h_cnt_reg1 < CHAR_WIDTH * 29))
            if(char_data[511 - ((h_cnt_reg1) % CHAR_WIDTH) - ((v_cnt_reg1) % CHAR_HEIGHT) * CHAR_WIDTH])
                vout <= BLACK;
            else
                vout <= WHITE;  
        else 
			vout <= fifo_rd_data;
	end

	always @( posedge clk )
	begin
			de_r1 <= (h_state == S_H_VALID && v_state == S_V_VALID );
			de_r2 <= de_r1;
			de_o  <= de_r2;
	end
	always @( posedge clk or negedge rst_n)
	begin
			if( ~rst_n ) begin
					vs_r1 <= 'd0;
					vs_r2 <= 'd0;
					vs_o  <= 'd0;
					
			end else if( frame_ena ) begin
					vs_r1 <= (v_state == S_V_SYNC);
					vs_r2 <= vs_r1;
					vs_o  <= vs_r2;
			end else begin
					vs_r1 <= 'd0;
					vs_r2 <= 'd0;
					vs_o  <= 'd0;
			end
	end
	
	always @( posedge clk or negedge rst_n )
	begin
			if( ~rst_n ) begin
					hs_r1 <= 'd0;
					hs_r2 <= 'd0;
					hs_o  <= 'd0;
					
			end else if( frame_ena )begin
					hs_r1 <= (h_state == S_H_SYNC);
					hs_r2 <= hs_r1;
					hs_o  <= hs_r2;
			end else begin
					hs_r1 <= 'd0;
					hs_r2 <= 'd0;
					hs_o  <= 'd0;
			end
	end         
	
	always @( posedge clk )
	begin
			fifo_rd_period <=  ~(v_state == S_V_SYNC && v_cnt == 0) ;
	end
	reg	fifo_rd_period_d0 = 1'b0;
	always @( posedge clk )
			fifo_rd_period_d0 <= fifo_rd_period;
	
	assign neg_fifo_rd_period = fifo_rd_period_d0 & (~fifo_rd_period);   
	assign fifo_rst = neg_fifo_rd_period;

endmodule
	