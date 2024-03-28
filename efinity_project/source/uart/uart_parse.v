module uart_parse(
	input	wire 		clk,
	input	wire 		rst_n, 
	input	wire 		rx_valid,
	input	wire [7:0]	rx_data, 
	input	wire 		tx_req,
	output	reg	 		tx_valid = 0,
	output	reg	 [7:0]	tx_data = 0,

	output  reg  [3:0] 	packet_type = 0,
	output	reg	 [15:0] start_x = 0,
	output	reg	 [15:0] start_y = 0,
	output	reg	 [15:0] end_x = 1920,
	output	reg	 [15:0] end_y = 1080,
	output	reg	 [15:0] size_x = 0,
	output	reg	 [15:0] size_y = 0,
	output	reg	 [7:0]  Algorithm = 0,
	output	reg	 		param_valid = 0
);

localparam PKT_HD0 	= 3'd0;
localparam PKT_HD1 	= 3'd1;
localparam RX_DATA 	= 3'd2;
localparam PKT_END0 = 3'd3;
localparam PKT_END1 = 3'd4;
localparam WR_RAM	= 3'd5;

localparam TIME_OUT_COUNT = 24'h4C4B40;

reg [2:0] 	state = PKT_HD0;
reg	[7:0]	rx_data_reg[9:1];
reg	[23:0] 	time_out_cnt  = 0;
reg			time_out = 1'b0;
reg			time_out_en = 1'b0;
reg	[4:0] 	data_num = 'd0;
reg [4:0] 	data_cnt = 'd1;

always @( posedge clk )
begin
	tx_data <= rx_data;
	tx_valid <= rx_valid;
end 

initial
begin
    rx_data_reg[1] = 8'h00;
    rx_data_reg[2] = 8'h00;
    rx_data_reg[3] = 8'h00;
    rx_data_reg[4] = 8'h00;
    rx_data_reg[5] = 8'h00;
    rx_data_reg[6] = 8'h00;
    rx_data_reg[7] = 8'h00;
    rx_data_reg[8] = 8'h00;
    rx_data_reg[9] = 8'h00;
end

always @( posedge clk or negedge rst_n)
begin
	if( ~rst_n ) begin
		state <= PKT_HD0;
	end else if(time_out ) begin
		state <= PKT_HD0;
	end else begin
		case( state )  
		PKT_HD0 : begin 					
			if( rx_valid && rx_data == 8'h00 ) begin
				state <= PKT_HD1;
			end 
		end
		PKT_HD1 : begin
			if( rx_valid && rx_data[7:4] == 4'h0 ) begin
				packet_type <= rx_data[3:0];
				state <= RX_DATA;
			end
		end
		RX_DATA : begin
			if( rx_valid ) begin
				rx_data_reg[data_cnt] <= rx_data;

				if( data_cnt == data_num ) begin
					state <= PKT_END0;
					data_cnt <= 'd1;
				end else begin
					data_cnt <= data_cnt + 1'b1;
				end 
			end
		end
		PKT_END0 : begin
			if( rx_valid && rx_data == 8'hff ) begin
				state <= PKT_END1;
			end 
		end 
		PKT_END1 : begin
			if( rx_valid  && rx_data == 8'h00) begin	//recevie FF
				state <= WR_RAM;
			end 
		end
		WR_RAM : begin
			state <= PKT_HD0;
		end	
		default: begin
			state <= PKT_HD0;
		end	
		endcase       
	end
end   

always @( posedge clk or negedge rst_n ) // 
begin
	if( !rst_n ) 
		data_num <= 'd0;
	else if(state == PKT_HD1 && rx_valid) begin		
		case(rx_data[3:0])	
			4'd0 : data_num <= 9;
			4'd1 : data_num <= 5;
			default: data_num <= 9;
		endcase
	end 
end 

always @( posedge clk )
begin
	if( state != PKT_HD0 ) begin
		if( rx_valid ) 
			time_out_en <= 1'b0;
		else 					 
			time_out_en <= 1'b1;
	end else begin
		time_out_en <= 1'b0;
	end 
end 

always @( posedge clk )
begin
	if(time_out_en ) begin
		if( time_out_cnt == TIME_OUT_COUNT-1 ) begin
			time_out <= 1'b1;
		end else begin
			time_out_cnt <= time_out_cnt + 1'b1;
			time_out <= 1'b0;
		end	
	end else begin
		time_out_cnt <= 0;
		time_out <= 1'b0;
	end	
end

always @( posedge clk )
begin
	if( !rst_n ) begin
		start_x <= 0;
		start_y <= 0;
		end_x <= 0;
		end_y <= 0;
		size_x <= 0;
		size_y <= 0;
		Algorithm <= 0;
		param_valid <= 0;
	end
	else if( state == WR_RAM ) begin
		case(packet_type[3:0])	
				4'd0 : begin // up
					start_x <= {rx_data_reg[1], rx_data_reg[2]};
					start_y <= {rx_data_reg[3], rx_data_reg[4]};
					end_x   <= {rx_data_reg[5], rx_data_reg[6]};
					end_y   <= {rx_data_reg[7], rx_data_reg[8]};
					Algorithm <= rx_data_reg[9];
				end 
				4'd1 : begin // down
					size_x <= {rx_data_reg[1], rx_data_reg[2]};
					size_y <= {rx_data_reg[3], rx_data_reg[4]};
					Algorithm <= rx_data_reg[5];
				end 
			default: ;
		endcase
		param_valid <= 1;
	end else begin
		start_x <= start_x;
		start_y <= start_y;
		end_x <= end_x;
		end_y <= end_y;
		size_x <= size_x;
		size_y <= size_y;
		Algorithm <= Algorithm;
		param_valid <= 0;
	end 
end       

endmodule