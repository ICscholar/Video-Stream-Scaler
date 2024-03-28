

module vid_rx_align #(
	parameter I_VID_WIDTH = 16,
	parameter AXI_DDR_WIDTH = 256
	 
)(
input		wire										clk		,    
input		wire										rst_n	,
input		wire										i_vs	, //active hgih
input		wire										i_de	, //active high
input		wire	[I_VID_WIDTH-1:0] 					vin,

output		reg											fifo_wr_en,
output		reg		[AXI_DDR_WIDTH-1:0]					fifo_wr_data = 'd0,
output		reg											frame_start = 1'b0,
output		reg											fifo_rst = 1'b0,
output		wire				[23:0]					frame_cnt  				


);

	localparam SHIFT_WIDTH = AXI_DDR_WIDTH/I_VID_WIDTH;
	localparam AXI_DATA_SIZE   = $clog2(SHIFT_WIDTH) ;
  reg	[I_VID_WIDTH-1:0] 								din_r0 =16'd0;
  reg	[SHIFT_WIDTH-1:0] 								shift_cnt = 0;
  
  reg													vs_r0 = 1'b0;
  reg													de_r0 = 1'b0;
  reg													de_r1 = 1'b0;
  wire 													neg_vs;
  wire													pos_vs;
  reg	[AXI_DDR_WIDTH-1:0]								wr_data = 'd0;
  reg													wr_en	;
  reg													r_frame_start = 1'b0; 
  reg 													fifo_reset_en = 1'b0;
  wire													frame_stable;
  reg		[3:0]										last_data_shift = 'd0;
  reg													last_shift_en = 'd0;
  reg		[3:0] 										last_cnt = 'd0;	
  reg		[1:0]										last_wr_state = 2'd0;	
  reg													last_wr_en = 'd0;	
  wire 													negtive_sync;							
  always @( posedge clk )
  begin
  		vs_r0 	<= i_vs;  		
  		de_r0 	<= i_de; 
  		de_r1 	<= de_r0;
  		din_r0  <= vin;
  end
  assign neg_vs = {vs_r0,i_vs} == 2'b10;   
  assign pos_vs = {vs_r0,i_vs} == 2'b01;

	always @( posedge clk )
  begin
  		if( (neg_vs && ~negtive_sync)||(pos_vs && negtive_sync) )
  				shift_cnt <= 'd1;
  		else if( de_r0 )
  				shift_cnt <= {shift_cnt[SHIFT_WIDTH-2:0],shift_cnt[SHIFT_WIDTH-1]};
  end
  
  always @( posedge clk )
  begin
  		if((neg_vs && ~negtive_sync)||(pos_vs && negtive_sync) )//if( neg_vs ) 
  				r_frame_start <= 1'b1;
  		else if( wr_en )
  				r_frame_start <= 1'b0;
  end    
  
  always@( posedge clk )
  begin
  		if((neg_vs && ~negtive_sync)||(pos_vs && negtive_sync) )//if( neg_vs )
  				fifo_reset_en <= 1'b1;
  		else if( de_r0 )
  				fifo_reset_en <= 1'b0;
  end
  //before every frame,reset the fifo first
  always @( posedge clk )
  			fifo_rst <= fifo_reset_en & de_r0 & frame_stable;  
  

 	always @( posedge clk )
 	begin
 			if( fifo_rst )
 					frame_start <= 1'b1;
 			else if( wr_en )
 					frame_start <= 1'b0;
 									
 	end
  					

  //write data Control
  always @( posedge clk )
  begin
  		if( de_r0 | last_shift_en) begin  				
  				wr_data <= {wr_data[AXI_DDR_WIDTH-I_VID_WIDTH-1:0],din_r0};
  		end
  end
  //write enable Control
  always @( posedge clk )
  begin
  		if( de_r0 & shift_cnt[SHIFT_WIDTH-1]) 
  				wr_en <= 1'b1;
  		else
  				wr_en <= 1'b0;
  end	       
  
  always @( posedge clk )  
  					fifo_wr_data <= wr_data;
  
  always @( posedge clk )
  begin
  		if(  frame_stable ) begin
		  		fifo_wr_en <= wr_en | last_wr_en;
		  end else 
		  		fifo_wr_en <= 1'b0;
  end   
  
  
frame_info_det u_frame_info_det(
/*i*/.clk			(clk		),    
/*i*/.rst_n			(rst_n	),
/*i*/.i_vs			(i_vs	  ), //active hgih
/*i*/.i_de			(i_de	  ), //active high
                    
/*o*/.frame_cnt_o	(frame_cnt),
/*o*/.frame_stable  (frame_stable	),
/*O*/.negtive_sync(negtive_sync)
);             



always @( posedge clk )
begin
		if((pos_vs && ~negtive_sync)||(neg_vs && negtive_sync) )//if( pos_vs )
				last_data_shift <= ~frame_cnt[AXI_DATA_SIZE-1:0];
end

always @( posedge clk )
begin
		if( last_wr_state == 2'd1 )
				last_shift_en <= 1'b1;
		else
				last_shift_en <= 1'b0;
end

always @( posedge clk )
begin
		if( last_wr_state == 2'd1 )
				last_cnt <= last_cnt + 1'b1;
		else
				last_cnt <= 'd0;
end
	//��Ϊ�Ӹ�λ�����ݣ�����Ҫ�������ƶ�����λ
	always @( posedge clk )
	begin
			case( last_wr_state )
			2'd0 : begin
					if(((pos_vs && ~negtive_sync)||(neg_vs && negtive_sync)) && ~shift_cnt[0] )//if( pos_vs & ~shift_cnt[0])
							last_wr_state <= 2'd1;
			end
			2'd1 : begin
					if( last_cnt == last_data_shift )
							last_wr_state <= 2'd2;
			end
			2'd2 : begin
							last_wr_state <= 2'd0;
			end
			default:;
			endcase
	end
	
	always @( posedge clk )
			if( last_wr_state == 2'd2 )
					last_wr_en <= 1'b1;
			else
					last_wr_en <= 1'b0;


endmodule
