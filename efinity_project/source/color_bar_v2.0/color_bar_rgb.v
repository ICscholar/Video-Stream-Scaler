
	module color_bar_rgb #(
			parameter HS_POLORY =1'b1,
			parameter VS_POLORY = 1'b1,
			parameter NUM_OF_PIXERS_PER_CLOCK = 2'b01,
			parameter H_FRONT_PORCH 	= 13'd100,
			parameter H_SYNC 			= 13'd100,
			parameter H_VALID 			= 13'd384,
			parameter H_BACK_PORCH 		= 13'd100,
			parameter V_FRONT_PORCH 	= 13'd4,
			parameter V_SYNC 			= 13'd5,
			parameter V_VALID 			= 13'd288,
			parameter V_BACK_PORCH 		= 13'd4,
			parameter TEST_MODE 		= 2'd0
	)(
	input		wire			clk,
	input 		wire 			rst_n,
	//`ifdef TEST_MODE == 2'b11
	input  wire [7:0]           i_rdata,
	input  wire [7:0] 			i_gdata,
	input  wire [7:0] 			i_bdata,
	//`endif
	output 	reg	[15:0] h_cnt = 0,
	output  reg	[15:0] v_cnt = 0,
	output	reg					hs = 0,
	output	reg					vs  = 0,
	output	reg					de = 1'b0,
	output wire [1:0]     		w_h_state,
	output wire [1:0] 			w_v_state,
	output	reg [7:0] 			rgb_r = 8'd0,    //像素数据、红色分量
	output	reg [7:0] 			rgb_g = 8'd0,    //像素数据、绿色分量
	output 	reg [7:0] 			rgb_b = 8'd0     //像素数据、蓝色分量
	
	);


//=========================================================
//
//=========================================================
	localparam WHITE_R 		= 8'hff;
	localparam WHITE_G 		= 8'hff;
	localparam WHITE_B 		= 8'hff;
	localparam YELLOW_R 	= 8'hff;
	localparam YELLOW_G 	= 8'hff;
	localparam YELLOW_B 	= 8'h00;                              	
	localparam CYAN_R 		= 8'h00;
	localparam CYAN_G 		= 8'hff;
	localparam CYAN_B 		= 8'hff;                             	
	localparam GREEN_R 		= 8'h00;
	localparam GREEN_G 		= 8'hff;
	localparam GREEN_B 		= 8'h00;
	localparam MAGENTA_R 	= 8'hff;
	localparam MAGENTA_G 	= 8'h00;
	localparam MAGENTA_B 	= 8'hff;
	localparam RED_R 		= 8'hff;
	localparam RED_G 		= 8'h00;
	localparam RED_B 		= 8'h00;
	localparam BLUE_R 		= 8'h00;
	localparam BLUE_G 		= 8'h00;
	localparam BLUE_B 		= 8'hff;
	localparam BLACK_R 		= 8'h00;
	localparam BLACK_G 		= 8'h00;
	localparam BLACK_B 		= 8'h00;
	
	
	localparam S_H_BACK_PORCH 	= 2'd0;
	localparam S_H_SYNC 		= 2'd1;
	localparam S_H_VALID 		= 2'd2;
	localparam S_H_FRONT_PORCH 	= 2'd3;
	localparam S_V_BACK_PORCH 	= 2'd0;
	localparam S_V_SYNC 		= 2'd1;
	localparam S_V_VALID 		= 2'd2;
	localparam S_V_FRONT_PORCH 	= 2'd3;
	
	reg	[1:0] 	h_state = S_H_SYNC;
	reg	[1:0] 	v_state = S_H_SYNC;
	reg	hs_r1 = 1'b0;
	reg vs_r1 = 1'b0;
	reg	de_r1 = 1'b0;

	assign w_h_state = h_state	;
	assign w_v_state = v_state	;

	always @( posedge clk or negedge rst_n )
	begin
		if( ~rst_n ) begin 
			h_state <= S_H_SYNC;
			h_cnt <= 0;
		end else begin 
			case(h_state )
			S_H_SYNC : begin
					if( h_cnt == H_SYNC - 1) begin
							h_cnt <= 0;
							h_state <= S_H_BACK_PORCH;
					end else 
							h_cnt <= h_cnt + 1'b1;
			end
			S_H_BACK_PORCH : begin

					if( h_cnt == H_BACK_PORCH - 1) begin
							h_cnt <= 0;
							h_state <= S_H_VALID;
					end else 
							h_cnt <= h_cnt + 1'b1;
			end

			S_H_VALID : begin
					if( h_cnt == H_VALID - 1) begin
							h_cnt <= 0;
							h_state <= S_H_FRONT_PORCH;
					end else 
							h_cnt <= h_cnt + 1'b1;
			end
			S_H_FRONT_PORCH : begin
					if( h_cnt == H_FRONT_PORCH - 1) begin
							h_cnt <= 0;
							h_state <= S_H_SYNC;
					end else 
							h_cnt <= h_cnt + 1'b1;
			end
			default: begin
					h_state <= S_H_SYNC;
					h_cnt <= 0;
			end
			endcase
		end 
	end
	
	always @( posedge clk or negedge rst_n  )
	begin
		if( ~rst_n ) begin 
			v_state <= S_V_SYNC;
			v_cnt <= 0;
		end else begin 
			case(v_state )

			S_V_SYNC : begin
					if( h_cnt == H_FRONT_PORCH - 1 && h_state == S_H_FRONT_PORCH ) begin
						if( v_cnt == V_SYNC - 1 ) begin 
							v_cnt <= 0;
							v_state <= S_V_BACK_PORCH;
						end else 
							v_cnt <= v_cnt + 1'b1;
					end
			end
			S_V_BACK_PORCH : begin
					if( h_cnt == H_FRONT_PORCH - 1 && h_state == S_H_FRONT_PORCH ) begin
						if( v_cnt == V_BACK_PORCH - 1 ) begin 
							v_cnt <= 0;
							v_state <= S_V_VALID;
						end else 
							v_cnt <= v_cnt + 1'b1;
					end
			end
			S_V_VALID : begin
					if( h_cnt == H_FRONT_PORCH - 1 && h_state == S_H_FRONT_PORCH ) begin
						if( v_cnt == V_VALID - 1 ) begin 
							v_cnt <= 0;
							v_state <= S_V_FRONT_PORCH;
						end else 
							v_cnt <= v_cnt + 1'b1;
					end
			end
			S_V_FRONT_PORCH : begin
					if( h_cnt == H_FRONT_PORCH - 1 && h_state == S_H_FRONT_PORCH ) begin
						if( v_cnt == V_FRONT_PORCH - 1 ) begin 
							v_cnt <= 0;
							v_state <= S_V_SYNC;
						end else 
							v_cnt <= v_cnt + 1'b1;
					end
			end
			default: begin
					v_state <= S_V_SYNC;
					v_cnt <= 0;
			end
			endcase
		end 
	end
	reg [23:0] data = 24'd0;

	generate
	    if(TEST_MODE  == 2'b00 ) begin : V_MIRROR_P//===========================================================
	    	always@(posedge clk or negedge  rst_n)
			begin
				if(~rst_n)
					data <= 'd0;
				else if( h_state == S_H_VALID && v_state == S_V_VALID )
					data <= data + 1'b1; 
				else
					data <= 'd0;
			end
		end else if( TEST_MODE == 2'b01 )begin : Clor //===============================================================
			wire pos_vs;
			assign pos_vs = {vs,vs_r1} == 2'b01 ;
			reg [5:0] frame_cnt = 6'd0;
			reg [23:0] data_buf = 24'd0;
			reg [2:0] color_state = 2'b00;
			always @( posedge clk or negedge rst_n )
			begin 
				if( ~rst_n )
					frame_cnt <= 0;
				else if( pos_vs )
					frame_cnt <= frame_cnt + 1'b1;
			end
			//EBU检测图从左至右依次为 白色、黄色、靛色、绿色 紫色、红色、蓝色、黑色
			always @( posedge clk )
			begin 
				case( color_state )
				3'b000 :  begin 

					data_buf <= {WHITE_R,WHITE_G,WHITE_B};
					if( &frame_cnt & pos_vs )
						color_state <= 3'b001;
				end 

				3'b001 :  begin 
						data_buf <= {YELLOW_R,YELLOW_G,YELLOW_B};
						if( &frame_cnt & pos_vs )
							color_state <= 3'b010;
				end

				3'b010 :  begin 
						data_buf <= {CYAN_R,CYAN_G,CYAN_B};
					if( &frame_cnt & pos_vs )
							color_state <= 3'b011;
				end

				3'b011 :  begin 
						data_buf <= {GREEN_R,GREEN_G,GREEN_B};


						if( &frame_cnt & pos_vs )
							color_state <= 3'b100;
				 end
				 3'b100 : begin 
						data_buf <= {MAGENTA_R,MAGENTA_G,MAGENTA_B};
						if( &frame_cnt & pos_vs )
							color_state <= 3'b101;
				 end 
				 3'b101: begin 
						data_buf <= {RED_R,RED_G,RED_B};  


						if( &frame_cnt & pos_vs )
							color_state <= 3'b110;
				 end
				 3'b110: begin 
						data_buf <= {BLUE_R,BLUE_G,BLUE_B};
						if( &frame_cnt & pos_vs )
							color_state <= 3'b111;
				 end
				 3'b111:begin 
						data_buf <= {BLACK_R,BLACK_G,BLACK_B};
						if( &frame_cnt & pos_vs )
							color_state <= 3'b000;
				 end 

				default:;
				endcase // color_state
			end

			always@(posedge clk or negedge  rst_n)
			begin
				if(~rst_n) begin
						data <= 0;
					end
				else if(h_state == S_H_VALID && v_state == S_V_VALID) 
						data <= data_buf ;
				else 	
						data <= 'd0;
			end

		end else if( TEST_MODE == 2'b10 )begin : ColorBar//===============================================================
			always@(posedge clk or negedge  rst_n)
			begin
				if(~rst_n) begin
						data <= 0;
				end else if(h_state == S_H_VALID ) begin
					if( h_cnt <H_VALID/8) 
						data <=  {WHITE_R,WHITE_G,WHITE_B};
					else if( h_cnt <H_VALID/8*2)
						data <= {YELLOW_R,YELLOW_G,YELLOW_B};
					else if( h_cnt <H_VALID/8*3)
						data <= {CYAN_R,CYAN_G,CYAN_B};
					else if(h_cnt <H_VALID/8*4)
						data <= {GREEN_R,GREEN_G,GREEN_B};
					else if(h_cnt <H_VALID/8*5)
						data <= {MAGENTA_R,MAGENTA_G,MAGENTA_B};
					else if(h_cnt <H_VALID/8*6)
						data <= {RED_R,RED_G,RED_B}; 
					else if(h_cnt <H_VALID/8*7)
						data <= {BLUE_R,BLUE_G,BLUE_B};
					else 
						data <= {BLACK_R,BLACK_G,BLACK_B};
				end else 
						data <= 'd0;	
			end 

		end else begin //=======================================================================================
			always@( posedge clk or negedge rst_n )
			begin 
				if( !rst_n ) begin
					data <= 'd0 ;
				end else begin
					data <= {i_rdata,i_gdata,i_bdata} ;
				end 
			end
		end //==================================================================================================
	endgenerate 
	
	
	always @( posedge clk or negedge rst_n )
	begin
		if( !rst_n ) begin
			rgb_r <= 'd0;//rgb_r_reg;
	       	rgb_g <= 'd0;//rgb_g_reg; 
	       	rgb_b <= 'd0;//rgb_b_reg;  
		end else begin
	       	rgb_r <= data[23:16];//rgb_r_reg;
	       	rgb_g <= data[15:8];//rgb_g_reg; 
	       	rgb_b <= data[7:0];//rgb_b_reg;  
		end 
	end

	
	always @( posedge clk or negedge rst_n )
	begin
		if( !rst_n ) begin
			de_r1 <= 'd0;
			de 	  <= 'd0;
		end else begin
			de_r1 <= (h_state == S_H_VALID & v_state == S_V_VALID );
			de    <= de_r1;
		end 
	end
	always @( posedge clk or negedge rst_n )
	begin
		if( !rst_n ) begin
			vs_r1 <= 'd0;
			vs 	  <= 'd0;
		end else begin
			vs_r1 <= (VS_POLORY == 1'b1) ? (v_state == S_V_SYNC) : ~(v_state == S_V_SYNC );
			vs    <= vs_r1;
		end 
	end
	
	always @( posedge clk or negedge rst_n)
	begin
		if( !rst_n ) begin
			hs_r1 <= 'd0;
			hs 	  <= 'd0;
		end else begin
			hs_r1 <= (HS_POLORY == 1'b1) ? (h_state == S_H_SYNC) : ~(h_state == S_H_SYNC);
			hs    <= hs_r1;
		end 
	end
	
	
	endmodule
	
	

