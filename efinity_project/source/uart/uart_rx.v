module uart_rx #(
	parameter BPS_CNT = 100,
	parameter CHECKSUM_MODE = 2'b00,	//00:space, 01:odd ,10:even ,11:mask
	parameter CHECKSUM_EN = 1'b0
)(
	input 			clk,
	input 			clear,
	input 			rxd,
	output [7:0] 	rx_data,
	output 			frame_error,
	output 			checksum_error, 
	output 			rx_valid			
);         
	
reg [3:0] BIT_NUM = 0;
always @( posedge clk )
begin
	if( CHECKSUM_EN )
		BIT_NUM <= 10;
	else
		BIT_NUM <= 9;
end

//==============================================================================
//idle state detect
//==============================================================================
reg [1:0] rxd_r = 2'b11;
	
always @( posedge clk )
begin
	rxd_r <= {rxd_r[0],rxd};
end
//detect the negedge rxd
wire neg_rxd; 
wire pos_rxd;
assign neg_rxd = (rxd_r == 2'b10);
assign pos_rxd = (rxd_r == 2'b01);
	
wire [15:0] bw_cnt ;
reg	[15:0] bw_cnt_r = 0;
wire bit_over;
reg bit_over_r;
reg cnt_en ;
	
always @( posedge clk )
begin
	if( neg_rxd )
		cnt_en <= 1'b1;
	else if(  rx_over_r)
		cnt_en <= 1'b0;
	else
		cnt_en <= cnt_en;
end

assign bit_over = (bw_cnt_r == BPS_CNT -2);
assign bw_cnt = cnt_en ? { ( bw_cnt_r == BPS_CNT -1)? 0 : (bw_cnt_r + 1'b1 ) }: 16'd0;
	
always @( posedge clk )
begin
	bw_cnt_r <= bw_cnt;
	bit_over_r <= bit_over;
end
	
wire [3:0] bit_cnt ;    
reg 	[3:0] bit_cnt_r = 0;
assign bit_cnt =  cnt_en ?{ bit_over_r ?( bit_cnt_r + 1'b1 ): bit_cnt_r}:4'd0;
	
always @( posedge clk )
begin
		bit_cnt_r <= bit_cnt;
end
	       
//capture point process 
wire [15:0]capture_p0 ;
wire [15:0]capture_p1 ;
assign capture_p0 = BPS_CNT[15:1] - BPS_CNT[15:2];
assign capture_p1 = BPS_CNT[15:1] + BPS_CNT[15:2];
reg [15:0] capture_p0_r = 0;
reg [15:0] capture_p1_r = 0;
	
always @( posedge clk )
begin
	capture_p0_r <= capture_p0;
	capture_p1_r <= capture_p1;	
end        
wire capture_p0_en;
wire capture_p1_en;
assign capture_p0_en = ( bw_cnt == capture_p0_r); 
assign capture_p1_en = ( bw_cnt == capture_p1_r);
reg [1:0] temp_cap_r = 0;
always @( posedge clk )
begin
	if( capture_p0_en )
		temp_cap_r[0] <= rxd_r;
	else if( capture_p1_en )
		temp_cap_r[1] <= rxd_r;
end

wire  compare_p;
wire save_p ;
wire check_sum_p ;
wire send_out_p;
reg [4:0] capture_p1_en_dly = 0;

always @( posedge clk )
begin
	capture_p1_en_dly[4:0] <= {capture_p1_en_dly[3:0],capture_p1_en};
end

assign compare_p = capture_p1_en_dly[0];
assign save_p =    capture_p1_en_dly[1]; 
assign check_sum_p = capture_p1_en_dly[2]; 
assign send_out_p = capture_p1_en_dly[3];   

reg [9:0] rx_data_r;
always @( posedge clk )
begin
	if(save_p) begin
		case(bit_cnt_r)
		4'd1 : rx_data_r[0] <= temp_cap_r[1];
		4'd2 : rx_data_r[1] <= temp_cap_r[1];
		4'd3 : rx_data_r[2] <= temp_cap_r[1];
		4'd4 : rx_data_r[3] <= temp_cap_r[1];
		4'd5 : rx_data_r[4] <= temp_cap_r[1];
		4'd6 : rx_data_r[5] <= temp_cap_r[1];
		4'd7 : rx_data_r[6] <= temp_cap_r[1];
		4'd8 : rx_data_r[7] <= temp_cap_r[1]; 
		4'd9 : rx_data_r[8] <= temp_cap_r[1];
		4'd10:rx_data_r[9] <= temp_cap_r[1];
		default:;
		endcase
	end
end               
	  
reg rx_over_r = 0; 
always @( posedge clk )
begin  
	if(save_p&&( bit_cnt_r == BIT_NUM ))
		rx_over_r <= 1'b1;
	else
		rx_over_r <= 1'b0;
end         
	
reg checksum_ok = 0;
always @( posedge clk )
begin
	if(CHECKSUM_EN) begin
		if( check_sum_p  && (bit_cnt_r == 9 ) ) begin
		case(CHECKSUM_MODE)
			2'b00 :checksum_ok <= ~rx_data_r[8];
			2'b01 :checksum_ok <= ^rx_data_r;
			2'b10 :checksum_ok <= ~^rx_data_r;
			2'b11 :checksum_ok <= rx_data_r[8];
			default:checksum_ok <= checksum_ok;
		endcase
		end
	end else begin
		checksum_ok <= 1'b1;
	end
end	

assign rx_valid = rx_over_r;
assign rx_data = rx_data_r[7:0];

//=================================================================
//state process
// bit 0 : capature_ok, bit 1 : checksum_ok
//	wire clear ;
reg [1:0] frame_error_r = 2'd0; 
//֡           ˼·  
always @( posedge clk )
begin
	if( clear )
		frame_error_r[0] <= 1'b0;
	else if(  compare_p) begin
		if( ^temp_cap_r )	//   Ϊ1  Ҳ         ݲ һ         ֡    
			frame_error_r[0] <= 1'b1;
	end else begin
			frame_error_r[0] <= frame_error_r[0];
	end
end         
	
always @(posedge clk )
begin
	if(CHECKSUM_EN&& (bit_cnt_r == 9 )) begin
		if(rx_data_r[BIT_NUM-1] == 0 )
			frame_error_r[1] <= 1'b1;
		else
			frame_error_r[1] <= 1'b0;
	end else begin
			frame_error_r[1] <= frame_error_r[1];
	end
end
assign frame_error 		= |frame_error_r;
assign checksum_error 	= ~checksum_ok;

endmodule