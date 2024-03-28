

module frame_info_det(
input		wire															clk	,    
input		wire															rst_n,
input		wire															i_vs, //active hgih
input		wire															i_de, //active high

output	reg			[23:0]										frame_cnt_o,
output	reg																frame_stable,
output	reg																negtive_sync
);

  
  reg													vs_r0 = 1'b0;
  reg													de_r0 = 1'b0;
  reg													de_r1 = 1'b0;
  wire 												neg_vs;
  wire												pos_vs;
  reg						[1:0]					frame_num = 'd0;  
  reg						[23:0]				frame_cnt = 'd0; 
  reg						[23:0] 				frame_len_d0 = 'd0;
  reg						[23:0] 				frame_len_d1 = 'd0; 
  reg						[23:0] 				frame_len_d2 = 'd0; 

  always @( posedge clk )
  begin
		if( i_de ) begin
				if( i_vs )
						negtive_sync <= 1'b1;
				else
						negtive_sync = 1'b0;
		end 
	
  end 
  always @( posedge clk )
  begin
  		vs_r0 	<= i_vs;  		
  		de_r0 	<= i_de; 
  		de_r1 	<= de_r0;
  end
  assign neg_vs = {vs_r0,i_vs} == 2'b10;   //video start
  assign pos_vs = {vs_r0,i_vs} == 2'b01;	 //video end
  
  
  always @( posedge clk or negedge rst_n )
  begin
  			if( ~rst_n )
  					frame_cnt <= 'd0;
			else if( ~negtive_sync ) begin 
  				if( neg_vs )
  					frame_cnt <= 'd0;
  				else if( de_r1 )
  					frame_cnt <= frame_cnt + 1'b1;
			end else begin
				if( pos_vs )
  					frame_cnt <= 'd0;
  				else if( de_r1 )
  					frame_cnt <= frame_cnt + 1'b1;
			
			end 
  					
  end
  
  always @( posedge clk or negedge rst_n )
  begin
  		if( ~rst_n )
  				frame_cnt_o <= 'd0;
		else if( ~negtive_sync ) begin
  			if( pos_vs )
  				frame_cnt_o <= frame_cnt;
		end else begin
			if( neg_vs )
  				frame_cnt_o <= frame_cnt;
		end 
  end
  
  always @( posedge clk or negedge rst_n )
  begin
  		if( !rst_n ) begin
  				frame_len_d0 <= 'd0; 
  				frame_len_d1 <= 'd0; 
  				frame_len_d2 <= 'd0; 
  		end else if( pos_vs ) begin
  				frame_len_d0 <= frame_cnt;
  				frame_len_d1 <= frame_len_d0;
  				frame_len_d2 <= frame_len_d1;
  		end
  end
  
  always @( posedge clk or negedge rst_n )
  begin
  		if( !rst_n ) begin
  				frame_stable <= 1'b0;
		end else if( ~negtive_sync ) begin
  			if( pos_vs ) begin
  				if( frame_len_d0 == frame_len_d1 && frame_len_d0 == frame_len_d2 )
  						frame_stable <= 1'b1;
  				else
  						frame_stable <= 1'b0;
  			end
		end else begin
			if( neg_vs ) begin
  				if( frame_len_d0 == frame_len_d1 && frame_len_d0 == frame_len_d2 )
  						frame_stable <= 1'b1;
  				else
  						frame_stable <= 1'b0;
  			end
		end 
  end
  


endmodule